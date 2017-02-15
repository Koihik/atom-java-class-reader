class JavaFileWriter
    def initialize
        @io = StringIO.new
    end

    def import(name)
        @io.write "import #{name};\n"
    end

    def new_line
        @io.write "\n"
    end

    def write(s)
        @io.write s
    end

    def to_s
        @io.string
    end
end
