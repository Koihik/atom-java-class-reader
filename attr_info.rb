require 'json'

class InnerClassInfo
    attr_reader :inner_class
    attr_reader :outer_class
    attr_reader :inner_name
    attr_reader :inner_access_flag

    def initialize io,context
        @inner_class = context.find_constant(io.read_short)
        @outer_class = context.find_constant(io.read_short)
        @inner_name = context.find_utf(io.read_short)
        @inner_access_flag = io.read_short
    end
end

class ExceptionInfo
    def initialize io,context
        @start_pc = io.read_short
        @end_pc = io.read_short
        @handle_pc = io.read_short
        @catch_type = context.find_constant(io.read_short)
    end
end

class LineNumberTableInfo
    def initialize io,context
        @start_pc = io.read_short
        @line_number = io.read_short
    end
end

class LocalVariableTableInfo
    def initialize io,context
        @start_pc = io.read_short
        @length = io.read_short
        @name = context.find_utf(io.read_short)
        @desc = context.find_utf(io.read_short)
        @index = io.read_short
    end
end

class CodeInfo
    def initialize io,context
        @max_stack = io.read_short
        @max_locals = io.read_short
        len = io.read_int
        @code = []
        jvm_code = JSON.parse(File.read("jvm_code.json"))
        offset = 0
        while len>0
            op = io.read_unsigned_byte
            k = "%02X" % op
            len -= 1
            op_desc = jvm_code[k]
            throw "unknown op code : #{k}" unless op_desc
            data = nil
            if op_desc[1] == 2
                data = io.read_short
                len -= 2
            elsif op_desc[1] == 4
                data = io.read_int
                len -= 4
            end
            e = [offset,op_desc[0]]
            e << data if data
            @code << e
            offset += 1
        end
        len.times{
            c = io.read_byte
            c += 255 if c < 0
            @code << c.to_s(16)
        }
        @exceptions = []
        io.read_short.times{
            @exceptions << ExceptionInfo.new(io,context)
        }
        @attrs = []
        io.read_short.times{
            @attrs << AttrInfo.new(io)
        }
        @attrs.each{|x|
            x.update context
        }
    end

    def to_s
        "[Code max_stack : #{@max_stack} , max_locals : #{@max_locals}
        op :
        #{@code.map{|x| x.join " "}.join "\n\t"}
        ]"
    end
end

class AttrInfo
    attr_reader :name
    attr_reader :data

    def initialize io
        @name = io.read_short
        @ori_data = io.read(io.read_int)
    end

    def update context
        @name = context.find_utf @name
        case @name
        when "Synthetic"
            # do nothing
        when "Deprecated"
            # do nothing
        when "ConstantValue"
            @data = context.find_constant(@ori_data.unpack("s>").first).val
        when "SourceFile"
            @data = context.find_utf(@ori_data.unpack("s>").first)
        when "InnerClasses"
            io = StringIO.new(@ori_data)
            @data = []
            io.read_short.times{
                @data << InnerClassInfo.new(io,context)
            }
        when "Code"
            io = StringIO.new(@ori_data)
            @data = CodeInfo.new(io,context)
        when "LineNumberTable"
            io = StringIO.new(@ori_data)
            @data = []
            io.read_short.times{
                @data << LineNumberTableInfo.new(io,context)
            }
        when "LocalVariableTable"
            io = StringIO.new(@ori_data)
            @data = []
            io.read_short.times{
                @data << LocalVariableTableInfo.new(io,context)
            }
        end
        @ori_data = nil
    end

    def to_s
        "[AttrInfo name : #{@name} data : #{@data}]"
    end
end
