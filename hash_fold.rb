class HashFold
	class Pool
		def initialize(hf, n)
			pool = n.times.map {
				c0, p0 = IO.pipe # parent -> children
				p1, c1 = IO.pipe # children -> parent
				fork do
					p0.close
					p1.close
					loop do
						input = Marshal.load(c0) rescue exit
						hash = {}
						hf.map(input) do |k,v|
							hf.hash_merge(hash, k, v)
						end
						Marshal.dump(hash, c1)
					end
				end
				c0.close
				c1.close
				[p0, p1]
			}
			@inputs = pool.map{|i,o| i}
			@outputs = pool.map{|i,o| o}
			@ichann = @inputs.dup
			@queue = []
			@results = []
		end

		def flush
			loop do
				if @ichann.empty?
					o, @ichann, e = IO.select([], @inputs, [])
					break if @ichann.empty?
				end
				break if @queue.empty?
				Marshal.dump(@queue.pop, @ichann.pop)
			end
		end
		private :flush

		def push(obj)
			@queue.push obj
			flush
		end

		def fill
			t = @results.size == 0 ? nil : 0
			ochann, i, e = IO.select(@outputs, [], [], t)
			return if ochann == nil
			ochann.each do
				c = ochann.pop
				begin 
					@results.push Marshal.load(c)
				rescue => e
					c.close
					@outputs.delete c
				end
			end
		end
		private :fill

		def result
			fill
			@results.pop
		end
	end

	def initialize(n=2)
		@pool = Pool.new(self, n)
	end

	def hash_merge(hash, k, v)
		if hash.key? k
			hash[k] = self.fold(hash[k], v)
		else
			hash[k] = v
		end
	end

	def start(inputs)
		inputs.each do |input|
			@pool.push(input)
		end

		hash = {}
		inputs.each do |input|
			@pool.result.each do |k,v|
				hash_merge(hash, k, v)
			end
		end
		hash
	end
end