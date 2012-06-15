class FFI::Gen
  def generate_rb
    writer = Writer.new "  ", "# "
    writer.puts "# Generated by ffi-gen. Please do not change this file by hand.", "", "require 'ffi'", "", "module #{@module_name}"
    writer.indent do
      writer.puts "extend FFI::Library"
      writer.puts "ffi_lib_flags #{@ffi_lib_flags.map(&:inspect).join(', ')}" if @ffi_lib_flags
      writer.puts "ffi_lib '#{@ffi_lib}'", ""
      writer.puts "def self.attach_function(name, *_)", "  begin; super; rescue FFI::NotFoundError => e", "    (class << self; self; end).class_eval { define_method(name) { |*_| raise e } }", "  end", "end", ""
      declarations.values.compact.uniq.each do |declaration|
        declaration.write_ruby writer
      end
    end
    writer.puts "end"
    writer.output
  end
  
  def to_ruby_type(full_type)
    canonical_type = Clang.get_canonical_type full_type
    data_array = case canonical_type[:kind]
    when :void            then [":void",       "nil"]
    when :bool            then [":bool",       "Boolean"]
    when :u_char          then [":uchar",      "Integer"]
    when :u_short         then [":ushort",     "Integer"]
    when :u_int           then [":uint",       "Integer"]
    when :u_long          then [":ulong",      "Integer"]
    when :u_long_long     then [":ulong_long", "Integer"]
    when :char_s, :s_char then [":char",       "Integer"]
    when :short           then [":short",      "Integer"]
    when :int             then [":int",        "Integer"]
    when :long            then [":long",       "Integer"]
    when :long_long       then [":long_long",  "Integer"]
    when :float           then [":float",      "Float"]
    when :double          then [":double",     "Float"]
    when :pointer
      pointee_type = Clang.get_pointee_type canonical_type
      result = nil
      case pointee_type[:kind]
      when :char_s
        result = [":string", "String"]
      when :record
        pointee_declaration = @declarations[Clang.get_cursor_type(Clang.get_type_declaration(pointee_type))]
        result = [pointee_declaration.ruby_name, pointee_declaration.ruby_name] if pointee_declaration and pointee_declaration.written
      when :function_proto
        declaration = @declarations[full_type]
        result = [":#{declaration.ruby_name}", "Proc(_callback_#{declaration.ruby_name}_)"] if declaration
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
        result = [":pointer", "FFI::Pointer(#{'*' * pointer_depth}#{pointer_target_name.to_ruby_classname})", pointer_target_name]
      end
      
      result
    when :record
      declaration = @declarations[canonical_type]
      declaration ? ["#{declaration.ruby_name}.by_value", declaration.ruby_name] : [":char", "unknown"] # TODO
    when :enum
      declaration = @declarations[canonical_type]
      declaration ? [":#{declaration.ruby_name}", "Symbol from _enum_#{declaration.ruby_name}_", declaration.name] : [":char", "unknown"] # TODO
    when :constant_array
      element_type_data = to_ruby_type Clang.get_array_element_type(canonical_type)
      size = Clang.get_array_size canonical_type
      ["[#{element_type_data[:ffi_type]}, #{size}]", "Array<#{element_type_data[:description]}>"]
    when :unexposed
      [":char", "unexposed"]
    else
      raise NotImplementedError, "No translation for values of type #{canonical_type[:kind]}"
    end
    
    { ffi_type: data_array[0], description: data_array[1], parameter_name: (data_array[2] || Name.new(self, data_array[1])).to_ruby_downcase }
  end
  
  class Name
    RUBY_KEYWORDS = %w{alias and begin break case class def defined do else elsif end ensure false for if in module next nil not or redo rescue retry return self super then true undef unless until when while yield BEGIN END}

    def to_ruby_downcase
      format :downcase, :underscores, RUBY_KEYWORDS
    end
    
    def to_ruby_classname
      format :camelcase, RUBY_KEYWORDS
    end
    
    def to_ruby_constant
      format :upcase, :underscores, RUBY_KEYWORDS
    end
  end
  
  class Enum
    def write_ruby(writer)
      shorten_names
      
      @constants.each do |constant|
        constant[:symbol] = ":#{constant[:name].to_ruby_downcase}"
      end
      
      writer.comment do
        writer.write_description @description
        writer.puts "", "<em>This entry is only for documentation and no real method. The FFI::Enum can be accessed via #enum_type(:#{ruby_name}).</em>"
        writer.puts "", "=== Options:"
        @constants.each do |constant|
          writer.puts "#{constant[:symbol]} ::"
          writer.write_description constant[:comment], false, "  ", "  "
        end
        writer.puts "", "@method _enum_#{ruby_name}_", "@return [Symbol]", "@scope class"
      end
      
      writer.puts "enum :#{ruby_name}, ["
      writer.indent do
        writer.write_array @constants, "," do |constant|
          "#{constant[:symbol]}, #{constant[:value]}"
        end
      end
      writer.puts "]", ""
    end
    
    def ruby_name
      @ruby_name ||= @name.to_ruby_downcase
    end
  end
  
  class StructOrUnion
    def write_ruby(writer)
      @fields.each do |field|
        field[:symbol] = ":#{field[:name].to_ruby_downcase}"
        field[:type_data] = @generator.to_ruby_type field[:type]
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
      
      @fields << { symbol: ":dummy", type_data: { ffi_type: ":char" } } if @fields.empty?

      unless @oo_functions.empty?
        writer.puts "module #{ruby_name}Wrappers"
        writer.indent do
          @oo_functions.each_with_index do |(name, function, return_type_declaration), index|
            parameter_names = function.parameters[1..-1].map { |parameter| !parameter[:name].empty? ? parameter[:name].to_ruby_downcase : "arg#{function.parameters.index(parameter)}" }
            writer.puts "" unless index == 0
            writer.puts "def #{name.to_ruby_downcase}(#{parameter_names.join(', ')})"
            writer.indent do
              cast = return_type_declaration ? "#{return_type_declaration.ruby_name}.new " : ""
              writer.puts "#{cast}#{@generator.module_name}.#{function.ruby_name}(#{(["self"] + parameter_names).join(', ')})"
            end
            writer.puts "end"
          end
        end
        writer.puts "end", ""
      end
            
      writer.puts "class #{ruby_name} < #{@is_union ? 'FFI::Union' : 'FFI::Struct'}"
      writer.indent do
        writer.puts "include #{ruby_name}Wrappers" unless @oo_functions.empty?
        writer.write_array @fields, ",", "layout ", "       " do |field|
          "#{field[:symbol]}, #{field[:type_data][:ffi_type]}"
        end
      end
      writer.puts "end", ""
      
      @written = true
    end
    
    def ruby_name
      @ruby_name ||= @name.to_ruby_classname
    end
  end
  
  class FunctionOrCallback
    def write_ruby(writer)
      @parameters.each do |parameter|
        parameter[:type_data] = @generator.to_ruby_type parameter[:type]
        parameter[:ruby_name] = !parameter[:name].empty? ? parameter[:name].to_ruby_downcase : parameter[:type_data][:parameter_name]
      end
      return_type_data = @generator.to_ruby_type @return_type
      
      writer.puts "@blocking = true" if @blocking
      writer.comment do
        writer.write_description @function_description
        writer.puts "", "<em>This entry is only for documentation and no real method.</em>" if @is_callback
        writer.puts "", "@method #{@is_callback ? "_callback_#{ruby_name}_" : ruby_name}(#{@parameters.map{ |parameter| parameter[:ruby_name] }.join(', ')})"
        @parameters.each do |parameter|
          writer.write_description parameter[:description], false, "@param [#{parameter[:type_data][:description]}] #{parameter[:ruby_name]} ", "  "
        end
        writer.write_description @return_value_description, false, "@return [#{return_type_data[:description]}] ", "  "
        writer.puts "@scope class"
      end
      
      ffi_signature = "[#{@parameters.map{ |parameter| parameter[:type_data][:ffi_type] }.join(', ')}], #{return_type_data[:ffi_type]}"
      if @is_callback
        writer.puts "callback :#{ruby_name}, #{ffi_signature}", ""
      else
        writer.puts "attach_function :#{ruby_name}, :#{@name.raw}, #{ffi_signature}", ""
      end
    end
    
    def ruby_name
      @ruby_name ||= @name.to_ruby_downcase
    end
  end
  
  class Constant
    def write_ruby(writer)
      writer.puts "#{@name.to_ruby_constant} = #{@value}", ""
    end
  end
end