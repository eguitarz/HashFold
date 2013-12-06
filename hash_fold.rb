class HashFold
	def start(filepaths)
		result = {}
		filepaths.each do |fp|
			self.map(fp) do |k, v|
				if result.key? k
					result[k] = self.fold(result[k], v)
				else
					result[k] = v
				end
			end
		end
		return result
	end
end