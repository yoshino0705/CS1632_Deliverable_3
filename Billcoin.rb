# Billcoin.rb
# Wei-Hao Chen
# Nick Sallinger

require 'Time'

class Billcoin
	def initialize(file_path)
		# everyone should start with 0 bill coins, unless SYSTEM grants
		@path = file_path
		@billcoins = Hash.new # ADDRESS (names) as hash, since it's case sensitive, no need to account for case
		@billcoins['SYSTEM'] = Float::INFINITY
		@current_timestamp = Time.at 0.0 # next ts must be greater, never the same or less
		@prev_hash = "0"

	end

	def get_hash(s)
		vals = s.unpack('U*').map {|x| ((x ** 2000) * ((x + 2) ** 21) - ((x + 5) ** 3))}
		vals = vals.inject(0, :+) % 65536
		return vals.to_s(16)
	end

	def parse_info(block)
		info = Hash.new
		info['original'] = block

		block = block.split('|')	# splits the block by the regex '|'
		raise "Invalid block format, should consist of only 5 elements" unless block.length == 5

		info['id'] = block[0].to_i
		info['prev_hash'] = block[1]
		info['transaction'] = block[2].split(':')	# splits transaction by the regex ':'
		info['ts'] = block[3]
		info['self_hash'] = block[4]
		return info
	end

	def get_string_to_hash(info)
		return "#{info['id']}|#{info['prev_hash']}|#{info['transaction'].join(':')}|#{info['ts']}"
	end

	def validate_address(address)
		success = true
		error_msg = ""
		if address.length > 6 or address.length < 1
			success = false
			error_msg = "Invalid address length for #{address}, should be at most 6 alphabetic characters."
		elsif not !address.match(/[^A-Za-z]/)
			success = false
			error_msg = "The address #{address} is not alphabetic."
		else

		end

		return success, error_msg
	end

	def update_billcoins(info)
		# reads the transactions and updates the @billcoins based on those transactions
		# returns false if the update encounted errors
		# returns true if the update was a success
		# creating an extra method for verifying the transactions would need to loop through
		# the entire dictionary, which would be time consuming
		success = true
		error_msg = ""
		transactions = info['transaction']

		transactions.each{ |t|
			from, to = t.split('>')		# splits to "FROM", "TO(AMOUNT)"
			to, amount = to.split('(')	# splits to "TO", "AMOUNT)"

			# validate the addresses first
			success, error_msg = validate_address(from)
			break unless success

			success, error_msg = validate_address(to)
			break unless success

			amount = amount.delete(')')	# removes the last ')'
			amount = amount.to_i

			if not @billcoins.include? from
				@billcoins[from] = 0
			end
			if not @billcoins.include? to
				@billcoins[to] = 0
			end	
					
			@billcoins[from] -= amount
			@billcoins[to] += amount

			if @billcoins[from] < 0
				success = false
				error_msg = "Invalid block, address #{from} has #{@billcoins[from]} billcoins!"
			end

			if @billcoins[to] < 0
				success = false
				error_msg = "Invalid block, address #{to} has #{@billcoins[to]} billcoins!"
			end

		}

		return success, error_msg
	end

	def validate_timestamps(info)
		success = true
		error_msg = ""
		prev_ts = @current_timestamp
		cur_ts = Time.at info['ts'].to_f
		success = cur_ts > prev_ts
		error_msg = "Previous timestamp #{prev_ts.to_s}.#{prev_ts.nsec} >= new timestamp #{cur_ts.to_i}.#{cur_ts.nsec}" unless success

		@current_timestamp = cur_ts

		return success, error_msg
	end

	def validate_hash(info)
		# passes in the parsed info
		string_to_hash = get_string_to_hash(info)
		correct_hash = get_hash(string_to_hash)
		#puts "correct_hash:" + correct_hash + "END" + correct_hash.length.to_s
		#puts "self_hash:" + info['self_hash'] + "END" + info['self_hash'].length.to_s
		return correct_hash.strip == info['self_hash'].strip
	end

	def validate_first_block(f_info)
		error_msg = ""
		success = true
		if f_info['id'] != 0
			error_msg = "Invalid block number #{f_info['id']}, should be 0"
			success = false
		elsif f_info['prev_hash'] != "0"
			error_msg = "Previous hash was #{f_info['prev_hash']}, should be 0"
			success = false
		elsif f_info['transaction'].length != 1
			error_msg = "Transaction count for first block was #{f_info['transaction'].length}, should be 1"
			success = false
		elsif not validate_hash(f_info)
			error_msg = "String #{f_info['original']} hash set to #{f_info['self_hash']}, should be #{get_hash(get_string_to_hash(f_info))}"
			success = false
		else
			# verifies the timestamps
			success, error_msg = validate_timestamps(f_info)
			#error_msg = "" unless not success

			# updates the transaction logs
			success, error_msg = update_billcoins(f_info)
			#error_msg = "" unless not success

		end

		return success, error_msg
	end

	def validate_block(info, line_number)
		error_msg = ""
		success = true
		if info['id'] != line_number
			error_msg = "Invalid block number #{info['id']}, should be #{line_number}"
			success = false
		elsif info['prev_hash'].strip != @prev_hash.strip
			error_msg = "Previous hash was #{info['prev_hash']}, should be #{@prev_hash}"
			success = false
		elsif not validate_hash(info)
			error_msg = "String #{info['original']} hash set to #{info['self_hash']}, should be #{get_hash(get_string_to_hash(info))}"
			success = false
		else
			# verifies the timestamps
			success, error_msg = validate_timestamps(info)
			error_msg = "" unless not success

			# updates the transaction logs
			success, error_msg = update_billcoins(info)
			error_msg = "" unless not success

		end

		return success, error_msg
	end

	def print_billcoins
		@billcoins.each_pair {|k, v| puts "#{k}: #{v} billcoins"}
	end

	def validate_block_chain()
		first_line = File.open(@path).first
		# first line block number must be 0, and must only have one transaction
		first_block = parse_info(first_line)
		s, e = validate_first_block(first_block)
		if not s
			puts "Line 0: #{e}"
			puts "BLOCKCHAIN INVALID"
			exit()
		end

		# update the values
		@prev_hash = first_block['self_hash']

		File.readlines(@path).drop(1).each.with_index do |line, line_num|
			# line_num will be used to check the block number
			# line_num + 1 == block number

   			block = parse_info(line)
   			s, e = validate_block(block, line_num + 1)
   			if not s
				puts "Line #{line_num + 1}: #{e}"
				puts "BLOCKCHAIN INVALID"
				exit()
			end

			# update the values
			@prev_hash = block['self_hash']

		end

		return nil
	end

end