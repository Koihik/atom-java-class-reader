class MethodInfo
    attr_reader :access_flag
    attr_reader :name
    attr_reader :desc
    attr_reader :attrs

    def initialize io
        @access_flag = io.read_short
        @name = io.read_short
        @desc = io.read_short

        @attrs = []
        io.read_short.times{
            @attrs << AttrInfo.new(io)
        }
    end

    def update(context)
        @name = context.find_utf(@name)
        @desc = context.find_utf(@desc)
        @attrs.each{|attr|
            attr.update(context)
        }
    end

    def to_s
        "[MethodInfo access_flag : #{@access_flag} , name : #{@name} , desc : #{@desc} , attrs : #{@attrs}]"
    end
end
