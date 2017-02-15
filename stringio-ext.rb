class StringIO
	def read_bool
		read(1).unpack("c")[0]
	end

	def read_byte
		read(1).unpack("c")[0]
	end

	def read_unsigned_byte
		read(1).unpack("C")[0]
	end

	def read_short
		read(2).unpack("s>")[0]
	end

	def read_unsigned_short
		read(2).unpack("S>")[0]
	end

	def read_int
		read(4).unpack("i>")[0]
	end

	def read_unsigned_int
		read(4).unpack("I>")[0]
	end

	def read_float
		read(4).unpack("g")[0]
	end

	def read_long
		read(8).unpack("q>")[0]
	end

	def read_double
		read(8).unpack("G")[0]
	end

	def read_utf
		len = read_short
		return "" if len == 0
		return read(len).force_encoding('utf-8')
	end

	# ================================================
	def write_bool(s)
		s = s ? 1 : 0
		write [s].pack("c")
	end

	def write_byte(s)
		write [s].pack("c")
	end

	def write_short(s)
		write [s].pack("s>")
	end

	def write_int(s)
		write [s].pack("i>")
	end

	def write_float(s)
		write [s].pack("g")
	end

	def write_long(s)
		write [s].pack("q>")
	end

	def write_double(s)
		write [s].pack("G")
	end

	def write_utf(s)
		write_short s.bytes.size
		write [s].pack("a*").force_encoding('utf-8')
	end

end
