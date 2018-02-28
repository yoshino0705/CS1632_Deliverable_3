# Billcoin.rb
# Wei-Hao Chen
# Nick Sallinger

class Billcoin
	def initialize(file_path)
		# everyone should start with 0 bill coins, unless SYSTEM grants
		@path = file_path
		@billcoins = Hash.new # ADDRESS (names) as hash, since it's case sensitive, no need to account for case
		@current_timestamp = 0.0 # next ts must be greater, never the same or less

	end

	def get_hash(s)
		vals = s.unpack('U*').map {|x| ((x ** 2000) * ((x + 2) ** 21) - ((x + 5) ** 3))}
		vals = vals.inject(0, :+) % 65536
		vals.to_s(16)
	end

	def parse_info(block)
		block = block.split('|')
		info = Hash.new
		info['id'] = block[0]
		info['hash'] = block[1]
		info['transaction'] = block[2]
		info['ts'] = block[3]
		info['next_hash'] = block[4]
		info
	end

	def validate()
		first_line = File.open(path).first
		# first line block number must be 0, and must only have one transaction

		File.readlines(path).drop(1).each.with_index do |line, line_num|
			# line_num will be used to check the block number
			# line_num + 1 == block number
   			puts "#{line_num}: #{line}"
		end

		nil
	end