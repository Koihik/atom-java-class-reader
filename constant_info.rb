class ConstantInfo
    attr_reader :tag
    attr_reader :val

    def initialize tag,io
        @tag = tag
        parse io
    end

    def parse io
    end

    def update context
    end

    def self.parse(io)
        map = {
            0 => NilConstantInfo,
            1 => UTFConstantInfo,
            3 => IntegerConstantInfo,
            4 => FloatConstantInfo,
            5 => LongConstantInfo,
            6 => DoubleConstantInfo,
            7 => ClassConstantInfo,
            8 => StringConstantInfo,
            9 => FieldConstantInfo,
            10 => MethodConstantInfo,
            11 => InterfaceMethodConstantInfo,
            12 => NameAndTypeConstantInfo
        }
        tag = io.read_byte
        clz = map[tag]
        return clz.new(tag,io)
    end
end

class NilConstantInfo < ConstantInfo
    def to_s
        return "[Nil Constant]"
    end
end

class UTFConstantInfo < ConstantInfo
    def to_s
        return "[UTF Constant : #{@val}]"
    end

    def parse io
        @val = io.read_utf
    end
end

class IntegerConstantInfo < ConstantInfo
    def to_s
        return "[Integer Constant : #{@val}]"
    end

    def parse io
        @val = io.read_int
    end
end

class FloatConstantInfo < ConstantInfo
    def to_s
        return "[Float Constant : #{@val}]"
    end

    def parse io
        @val = io.read_float
    end
end

class LongConstantInfo < ConstantInfo
    def to_s
        return "[Long Constant : #{@val}]"
    end

    def parse io
        @val = io.read_long
    end
end

class DoubleConstantInfo < ConstantInfo
    def to_s
        return "[Double Constant : #{@val}]"
    end

    def parse io
        @val = io.read_double
    end
end

class ClassConstantInfo < ConstantInfo
    def to_s
        return "[Class Constant : #{@val}]"
    end

    def parse io
        @val = io.read_short
    end

    def update context
        @val = context.find_utf @val
    end
end

class StringConstantInfo < ConstantInfo
    def to_s
        return "[String Constant : #{@val}]"
    end

    def parse io
        @val = io.read_short
    end

    def update context
        @val = context.find_utf @val
    end
end

class FieldConstantInfo < ConstantInfo
    def to_s
        return "[Field Constant : #{@val}]"
    end

    def parse io
        @val = [io.read_short,io.read_short]
    end

    def update context
        @val[0] = context.find_constant @val[0]
        @val[1] = context.find_constant @val[1]
    end
end

class MethodConstantInfo < ConstantInfo
    def to_s
        return "[Method Constant : #{@val}]"
    end

    def parse io
        @val = [io.read_short,io.read_short]
    end

    def update context
        @val[0] = context.find_constant @val[0]
        @val[1] = context.find_constant @val[1]
    end
end

class InterfaceMethodConstantInfo < ConstantInfo
    def to_s
        return "[InterfaceMethod Constant : #{@val}]"
    end

    def parse io
        @val = [io.read_short,io.read_short]
    end

    def update context
        @val[0] = context.find_constant @val[0]
        @val[1] = context.find_constant @val[1]
    end
end

class NameAndTypeConstantInfo < ConstantInfo
    def to_s
        return "[NameAndType Constant : #{@val}]"
    end

    def parse io
        @val = [io.read_short,io.read_short]
    end

    def update context
        @val[0] = context.find_utf @val[0]
        @val[1] = context.find_utf @val[1]
    end
end
