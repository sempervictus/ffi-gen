class FFI::Gen
  def generate_java
    writer = Writer.new "    ", " * ", "/**", " */"
    writer.puts "// Generated by ffi-gen. Please do not change this file by hand.", "import java.util.*;", "import com.sun.jna.*;", "import java.lang.annotation.*;", "import java.lang.reflect.Method;", "", "public interface #{@module_name} extends Library {"
    writer.indent do
      writer.puts "", *IO.readlines(File.join(File.dirname(__FILE__), "java_pre.java")).map(&:rstrip)
      writer.puts "", "public static #{@module_name} INSTANCE = JnaInstanceCreator.createInstance();", ""
      writer.puts "static class JnaInstanceCreator {"
      writer.indent do
        writer.puts "private static #{@module_name} createInstance() {"
        writer.indent do
          writer.puts "DefaultTypeMapper typeMapper = new DefaultTypeMapper();", "typeMapper.addFromNativeConverter(NativeEnum.class, new EnumConverter());", "typeMapper.addToNativeConverter(NativeEnum.class, new EnumConverter());", ""
          writer.puts "Map<String, Object> options = new HashMap<String, Object>();", "options.put(Library.OPTION_FUNCTION_MAPPER, new NativeNameAnnotationFunctionMapper());", "options.put(Library.OPTION_TYPE_MAPPER, typeMapper);", ""
          writer.puts "return (#{@module_name}) Native.loadLibrary(\"#{@ffi_lib}\", #{@module_name}.class, options);"
        end
        writer.puts "}"
      end
      writer.puts "}", ""
      declarations.values.compact.uniq.each do |declaration|
        declaration.write_java writer
      end
    end
    writer.puts "}"
    writer.output
  end
  
  def to_java_type(full_type, is_array = false)
    canonical_type = Clang.get_canonical_type full_type
    data_array = case canonical_type[:kind]
    when :void            then ["void",       "nil"]
    when :bool            then ["boolean",    "Boolean"]
    when :u_char          then ["byte",       "Integer"]
    when :u_short         then ["short",      "Integer"]
    when :u_int           then ["int",        "Integer"]
    when :u_long          then ["NativeLong", "Integer"]
    when :u_long_long     then ["long",       "Integer"]
    when :char_s, :s_char then ["byte",       "Integer"]
    when :short           then ["short",      "Integer"]
    when :int             then ["int",        "Integer"]
    when :long            then ["NativeLong", "Integer"]
    when :long_long       then ["long",       "Integer"]
    when :float           then ["float",      "Float"]
    when :double          then ["double",     "Float"]
    when :pointer
      if is_array
        element_type = to_java_type Clang.get_pointee_type(canonical_type)
        return { jna_type: "#{element_type[:jna_type]}[]", description: "Array of #{element_type[:description]}", parameter_name: element_type[:parameter_name] }
      end
      
      pointee_type = Clang.get_pointee_type canonical_type
      result = nil
      case pointee_type[:kind]
      when :char_s
        result = ["String", "String"]
      when :record
        pointee_declaration = @declarations[Clang.get_cursor_type(Clang.get_type_declaration(pointee_type))]
        result = [pointee_declaration.java_name, pointee_declaration.java_name] if pointee_declaration and pointee_declaration.written
      when :function_proto
        declaration = @declarations[full_type]
        result = [":#{declaration.java_name}", "Proc(_callback_#{declaration.java_name}_)"] if declaration
      end
      
      if result.nil?
        pointer_depth = 0
        pointer_target_name = ""
        current_type = full_type
        loop do
          declaration = Clang.get_type_declaration current_type
          pointer_target_name = Name.new self, Clang.get_cursor_spelling(declaration).to_s_and_dispose
          break if not pointer_target_name.empty?

          case current_type[:kind]
          when :pointer
            pointer_depth += 1
            current_type = Clang.get_pointee_type current_type
          when :unexposed
            break
          else
            pointer_target_name = Name.new self, Clang.get_type_kind_spelling(current_type[:kind]).to_s_and_dispose
            break
          end
        end
        result = ["Pointer", "FFI::Pointer(#{'*' * pointer_depth}#{pointer_target_name.to_java_classname})", pointer_target_name]
      end
      
      result
    when :record
      declaration = @declarations[canonical_type]
      declaration ? ["#{declaration.java_name}.by_value", declaration.java_name] : ["byte", "unknown"] # TODO
    when :enum
      declaration = @declarations[canonical_type]
      declaration ? [declaration.java_name, "Symbol from _enum_#{declaration.java_name}_", declaration.name] : ["byte", "unknown"] # TODO
    when :constant_array
      element_type_data = to_java_type Clang.get_array_element_type(canonical_type)
      size = Clang.get_array_size canonical_type
      ["[#{element_type_data[:jna_type]}, #{size}]", "Array<#{element_type_data[:description]}>"]
    else
      raise NotImplementedError, "No translation for values of type #{canonical_type[:kind]}"
    end
    
    { jna_type: data_array[0], description: data_array[1], parameter_name: (data_array[2] || Name.new(self, data_array[1])).to_java_downcase }
  end
  
  class Name
    JAVA_KEYWORDS = %w{abstract assert boolean break byte case catch char class const continue default do double else enum extends final finally float for goto if implements import instanceof int interface long native new package private protected public return short static strictfp super switch synchronized this throw throws transient try void volatile while}
    
    def to_java_downcase
      format :camelcase, :initial_downcase, JAVA_KEYWORDS
    end
    
    def to_java_classname
      format :camelcase, JAVA_KEYWORDS
    end
    
    def to_java_constant
      format :upcase, :underscores, JAVA_KEYWORDS
    end
  end
  
  class Enum
    def write_java(writer)
      shorten_names
      
      @constants.each do |constant|
        constant[:symbol] = ":#{constant[:name].to_ruby_downcase}"
      end
      
      writer.comment do
        writer.write_description @description
        # TODO constant comments
      end
      
      writer.puts "public enum #{java_name} implements NativeEnum {"
      writer.indent do
        writer.write_array @constants, "," do |constant|
          "#{constant[:name].to_java_constant}(#{constant[:value]})"
        end
        writer.puts ";"
        
        writer.puts "", "private int nativeInt;", "", "private #{java_name}(int nativeInt) {", "    this.nativeInt = nativeInt;", "}", "", "@Override", "public int toNativeInt() {", "    return nativeInt;", "}"
      end
      writer.puts "}", ""
    end
    
    def java_name
      @java_name ||= @name.to_java_classname
    end
  end
  
  class StructOrUnion
    def write_java(writer)
      @fields.each do |field|
        field[:symbol] = field[:name].to_java_downcase
        field[:type_data] = @generator.to_java_type field[:type]
      end
      
      writer.comment do
        writer.write_description @description
        unless @fields.empty?
          writer.puts "", "= Fields:"
          @fields.each do |field|
            writer.puts "#{field[:symbol]} ::"
            writer.write_description field[:comment], false, "  (#{field[:type_data][:description]}) ", "  "
          end
        end
      end
      
      writer.puts "public static class #{java_name} extends #{@is_union ? 'Union' : (@fields.empty? ? 'PointerType' : 'Structure')} {"
      writer.indent do
        @fields.each do |field|
          writer.puts "public #{field[:type_data][:jna_type]} #{field[:symbol]};"
        end
        writer.puts "// hidden structure" if @fields.empty?
      end
      writer.puts "}", ""
      
      @written = true
    end
    
    def java_name
      @java_name ||= @name.to_java_classname
    end
  end
  
  class FunctionOrCallback
    def write_java(writer)
      return if @is_callback # not yet supported
      
      @parameters.each do |parameter|
        parameter[:type_data] = @generator.to_java_type parameter[:type], parameter[:is_array]
        parameter[:java_name] = !parameter[:name].empty? ? parameter[:name].to_java_downcase : parameter[:type_data][:parameter_name]
        parameter[:description] = []
      end
      return_type_data = @generator.to_java_type @return_type
      
      writer.comment do
        writer.write_description @function_description
        writer.puts "", "<em>This entry is only for documentation and no real method.</em>" if @is_callback
        writer.puts "", "@method #{@is_callback ? "_callback_#{java_name}_" : java_name}(#{@parameters.map{ |parameter| parameter[:java_name] }.join(', ')})"
        @parameters.each do |parameter|
          writer.write_description parameter[:description], false, "@param [#{parameter[:type_data][:description]}] #{parameter[:java_name]} ", "  "
        end
        writer.write_description @return_value_description, false, "@return [#{return_type_data[:description]}] ", "  "
        writer.puts "@scope class"
      end
      
      jna_signature = "#{@parameters.map{ |parameter| "#{parameter[:type_data][:jna_type]} #{parameter[:java_name]}" }.join(', ')}"
      if @is_callback
        writer.puts "callback :#{java_name}, #{jna_signature}", ""
      else
        writer.puts "@NativeName(\"#{@name.raw}\")", "#{return_type_data[:jna_type]} #{java_name}(#{jna_signature});", ""
      end
    end
    
    def java_name
      @java_name ||= @name.to_java_downcase
    end
  end
  
  class Constant
    def write_java(writer)
      writer.puts "public static int #{@name.to_java_constant} = #{@value};", ""
    end
  end
end