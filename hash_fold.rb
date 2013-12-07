class HashFold
	def merge_hash(hash, k, v)
		if hash.key? k
			hash[k] = self.fold(hash[k], v)
		else
			hash[k] = v
		end
	end

	def start(filepaths)
		result = nil
		filepaths.map do |fp|
			read,write = IO.pipe
			fork do
				read.close
				h = {}
				self.map(fp) do |k,v|
					merge_hash(h, k, v)
				end
				Marshal.dump(h, write)
				write.close
			end
			read
		end.each do |r|
			h = Marshal.load r
			if result
				h.each do |k,v|
					merge_hash(hash, k, v)
				end
			else
				result = h
			end
		end
		result
	end
end