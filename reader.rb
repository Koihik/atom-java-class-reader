require 'stringio'
require_relative 'stringio-ext.rb'
require_relative 'access_flag.rb'

require_relative 'constant_info.rb'
require_relative 'attr_info.rb'
require_relative 'field_info.rb'
require_relative 'method_info.rb'

require_relative 'java_file_writer.rb'

class JClassFile
    def find_constant idx
        @constant_pool[idx]
    end

    def find_utf idx
        @constant_pool[idx].val
    end

    def initialize(path)
        data2 = ""
        File.open(path, "rb") do |infile|
            while (line = infile.gets)
                data2 += line
            end
        end

        io = StringIO.new(data2)
        magic = io.read_unsigned_int
        raise "file : #{path} is not a java class file" unless magic == 0xCAFEBABE

        @minor_version = io.read_short
        @major_version = io.read_short

        @constant_pool = [NilConstantInfo.new(nil,nil)]
        len = io.read_short
        (len-1).times{|idx|
            info = ConstantInfo.parse(io)
            @constant_pool << info
            @constant_pool << info if info.is_a?(LongConstantInfo) || info.is_a?(DoubleConstantInfo)
        }


        @access_flag = io.read_byte

        @this_class = io.read_short
        @super_class = io.read_short

        @interfaces = []
        (io.read_short).times{
            @interfaces << io.read_short
        }

        @fields = []
        io.read_short.times{
            @fields << FieldInfo.new(io)
        }

        @methods = []
        io.read_short.times{
            @methods << MethodInfo.new(io)
        }

        @attrs = []
        io.read_short.times{
            @attrs << AttrInfo.new(io)
        }

        @constant_pool.each{|x|
            x.update self
        }
        @fields.each{|x|
            x.update self
        }
        @methods.each{|x|
            x.update self
        }
        @attrs.each{|x|
            x.update self
        }

        @this_class = find_utf(@this_class)
        @super_class = find_utf(@super_class)

        # puts "minor_version = #{@minor_version}"
        # puts "major_version = #{@major_version}"
        # puts "access_flag = #{@access_flag.to_s(16)}"
        # puts "this_class = #{@this_class}"
        # puts "super_class = #{@super_class}"

        # @constant_pool.each_with_index{|info,idx|
        #     next if idx == 0
        #     puts "idx = #{idx} , info = #{info}"
        # }
        # @fields.each{|field|
        #     puts field
        # }
        # @methods.each{|method|
        #     puts "=======#{method.name}========"
        #     puts method.attrs[0].data
        # }
        # @attrs.each{|field|
        #     puts field
        # }
    end


    def to_java
        intent = "    "
        w = JavaFileWriter.new
        # import
        @constant_pool.each{|constant|
            if constant.is_a?(ClassConstantInfo)
                name = constant.val.split("/").join(".")
                w.import(name) unless name =~ /java\.lang\./ || name == @this_class
            end
        }
        w.new_line

        w.write "#{@access_flag.to_class_flag} #{@this_class} {\n"
        @fields.each{|field|
            access = field.access_flag.to_field_flag
            access += " " if access != ""
            w.write "#{intent}#{access}#{field.desc.to_type} #{field.name};\n"
        }
        w.new_line
        @methods.each{|method|
            desc = method.desc.to_method_desc

            ret = desc[0]
            attr_str = ""
            1.upto(desc.length-1){|i|
                attr_str += "#{desc[i]} arg#{i}"
            }
            access = method.access_flag.to_field_flag
            access += " " if access != ""
            w.write "#{intent}#{access}#{ret} #{method.name}(#{attr_str}){\n"
            w.write "#{intent*2}\n"
            w.write "#{intent}}\n"
            w.new_line
        }

        w.write "}\n"

        return w.to_s
    end
end

puts JClassFile.new("HelloWorld.class").to_java
