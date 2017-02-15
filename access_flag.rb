class Fixnum
    def to_class_flag
        s = ""
        s += "public" if self & 0x0001 != 0
        s += " final" if self & 0x0010 != 0
        s += " abstract" if self & 0x0400 != 0
        if self & 0x0200 != 0
            s += " interface"
        elsif self & 0x4000 != 0
            s += " enum"
        else
            s += " class"
        end
        s += " @" if self & 0x2000 != 0
        s.lstrip!
        return s
    end

    def to_field_flag
        s = ""
        s += "public" if self & 0x0001 != 0
        s += "private" if self & 0x0002 != 0
        s += "protected" if self & 0x0004 != 0
        s += " static" if self & 0x0008 != 0
        s += " final" if self & 0x0010 != 0
        s += " volatile" if self & 0x0040 != 0
        s += " transent" if self & 0x0080 != 0
        s.lstrip!
        return s
    end

    def to_method_flag
        s = ""
        s += "public" if self & 0x0001 != 0
        s += "private" if self & 0x0002 != 0
        s += "protected" if self & 0x0004 != 0
        s += " static" if self & 0x0008 != 0
        s += " final" if self & 0x0010 != 0
        s += " sychronized" if self & 0x0020 != 0
        s += " native" if self & 0x0100 != 0
        s += " abstract" if self & 0x0400 != 0
        s.lstrip!
        return s
    end
end

class String
    def to_type
        return "" if self == ""
        suffix = ""
        s = self
        while s[0] == "["
            suffix += "[]"
            s = s[1,s.length-1]
        end
        return "byte#{suffix}" if s == "B"
        return "char#{suffix}" if s == "C"
        return "double#{suffix}" if s == "D"
        return "float#{suffix}" if s == "F"
        return "int#{suffix}" if s == "I"
        return "long#{suffix}" if s == "J"
        return "short#{suffix}" if s == "S"
        return "boolean#{suffix}" if s == "Z"
        return "void#{suffix}" if s == "V"
        s = s[1,s.length-2]
        s.gsub!(/\//,".")
        s += suffix
        return s
    end

    def to_method_desc
        attrs = /(?<=\()[\w\W]+(?=\))/.match(self).to_s
        ret = /(?<=\))\w+/.match(self).to_s
        s = [ret.to_type]
        idx = 0
        arr_prefix = ""
        while idx < attrs.length
            c = attrs[idx]
            if c == "["
                arr_prefix += c
                idx += 1
            elsif c == "L"
                remain = attrs[idx,attrs.length-idx]
                len = remain.index(";") + 1
                s << "#{arr_prefix}#{attrs[idx,len]}".to_type
                arr_prefix = ""
                idx += len
            else
                s << "#{arr_prefix}#{c}".to_type
                arr_prefix = ""
                idx += 1
            end
        end
        s
    end

end

# puts "(IJLjava/lang/String;Ljava/lang/String;)V".to_method_desc
