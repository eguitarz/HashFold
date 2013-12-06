$:.unshift File.dirname(__FILE__)

require 'hash_fold'
require 'word_count'

WordCount.new.start(ARGV).sort_by{ |x| x[1] }.reverse.take(20).each do |k,v|
	puts "#{k}: #{v}\n"
end