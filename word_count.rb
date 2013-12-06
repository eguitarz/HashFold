require 'hash_fold'

class WordCount < HashFold
	IGNORE_WORDS = %w(a an and are as be for if in is it of or the to with)

	def map(document)
		open(document) do |f|
			for line in f
				line.gsub!( /[!#"'$%^&*()-=,.<>;:\[\]-_`~\/\|{}]/, ' ')

				for word in line.split
					word.downcase!
					next if IGNORE_WORDS.include? word
					yield word.strip, 1
				end
			end
		end
	end

	def fold(count1, count2)
		return count1 + count2
	end
end