# Billcoin.rb
# Wei-Hao Chen
# Nick Sallinger

class Billcoin
	attr_accessor :path, :billcoins, :current_timestamp, :prev_hash

	def initialize(file_path)		
		@path = file_path
		@billcoins = Hash.new # ADDRESS (names) as hash, since it's case sensitive, no need to account for case
		@billcoins['SYSTEM'] = Float::INFINITY
		@current_timestamp = {'sec':-1,'nsec':-1} # next ts must be greater, never the same or less
		@prev_hash = "0"

	end

	# returns the hash of the given string
	def get_hash(s)
		vals = s.unpack('U*').map {|x| ((x ** 2000) * ((x + 2) ** 21) - ((x + 5) ** 3))}
		vals = vals.inject(0, :+) % 65536
		return vals.to_s(16)
	end

	# parses a block string into an useful information dictionary
	def parse_info(block)
		info = Hash.new
		info['original'] = block

		block = block.split('|')	# splits the block by the regex '|'
		if block.length != 5
			puts 'Invalid block format, should consist of only 5 elements'
			puts 'BLOCKCHAIN INVALID'
			exit()
		end		

		info['id'] = block[0].to_i
		info['prev_hash'] = block[1]
		info['transaction'] = block[2].split(':')	# splits transaction by the regex ':'
		info['ts'] = {'sec': block[3].split('.')[0].to_i, 'nsec': block[3].split('.')[1].to_i}
		#puts info['ts']
		info['self_hash'] = block[4]
		return info
	end

	# returns string containing the info necessary to hash
	def get_string_to_hash(info)
		return "#{info['id']}|#{info['prev_hash']}|#{info['transaction'].join(':')}|#{info['ts'][:sec]}.#{info['ts'][:nsec]}".strip
	end

	# validates the address of a transaction
	# where it must be alphabetic and less than 6 characters and more than 1 character
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

	# validates the billcoin count of the address
	def validate_billcoins(address)
		if not @billcoins.include? address
			return false, "Internal Error: #{address} does not exist in the billcoin dictionary"
		end

		if @billcoins[address] < 0
			success = false
			error_msg = "Invalid block, address #{address} has #{@billcoins[address]} billcoins!"
			return success, error_msg
		end

		return true, ''
	end

	# updates the dictionary that keeps track of each address's billcoins
	def update_billcoins(info)
		# reads the transactions and updates the @billcoins based on those transactions
		# returns false if the update encounted errors
		# returns true if the update was a success
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

			#puts "#{from}: #{@billcoins[from]} sent #{to}: #{@billcoins[to]}"

			success, error_msg = validate_billcoins(from)
			return success, error_msg unless success

			success, error_msg = validate_billcoins(to)
			return success, error_msg unless success
		}

		return success, error_msg
	end

	# validates the timestamp
	# where the given timestamp must be greater than the previous timestamp
	def validate_timestamps(info)
		prev_ts = @current_timestamp
		cur_ts = info['ts']

		if cur_ts[:sec] > prev_ts[:sec]
			success = true
		elsif cur_ts[:sec] == prev_ts[:sec]
			(cur_ts[:nsec] > prev_ts[:nsec]) ? success = true : success = false
		else
			success = false
		end
				
		#puts success
		error_msg = "Previous timestamp #{prev_ts[:sec]}.#{prev_ts[:nsec]} >= new timestamp #{cur_ts[:sec]}.#{cur_ts[:nsec]}" unless success

		@current_timestamp = cur_ts
		#puts "Seconds #{cur_ts[:sec]} >= #{prev_ts[:sec]}: #{cur_ts[:sec] >= prev_ts[:sec]} where success: #{success}"
		#puts "Nano #{cur_ts[:nsec]} > #{prev_ts[:nsec]}: #{cur_ts[:nsec] > prev_ts[:nsec]} where success: #{success}"
		return success, error_msg
	end

	# validates the hash part of the 'info' dictionary given
	# where the method will compare the correct hash to the given one
	def validate_hash(info)
		# passes in the parsed info
		string_to_hash = get_string_to_hash(info)
		correct_hash = get_hash(string_to_hash)
		#puts string_to_hash
		return correct_hash.strip == info['self_hash'].strip
	end

	# validates the first block of the chain
	# it had to be done separate since the first block (genesis block) must 
	# only have one transaction
	# and its previous hash is 0
	def validate_first_block(f_info)
		error_msg = ""
		success = true

		# verifies the timestamps
		success, error_msg = validate_timestamps(f_info)
		return success, error_msg unless success

		if f_info['id'] != 0
			error_msg = "Invalid block number #{f_info['id']}, should be 0"
			success = false
			return success, error_msg
		elsif f_info['prev_hash'] != "0"
			error_msg = "Previous hash was #{f_info['prev_hash']}, should be 0"
			success = false
			return success, error_msg
		elsif f_info['transaction'].length != 1
			error_msg = "Transaction count for first block was #{f_info['transaction'].length}, should be 1"
			success = false
			return success, error_msg
		elsif not validate_hash(f_info)
			error_msg = "String #{f_info['original'].strip} hash set to #{f_info['self_hash'].strip}, should be #{get_hash(get_string_to_hash(f_info))}"
			success = false
			return success, error_msg
		else			
			# updates the transaction logs
			success, error_msg = update_billcoins(f_info)
			#error_msg = "" unless not success
			return success, error_msg unless success
		end

		return success, error_msg
	end

	# validates the rest of the blocks in the chain
	# which are not the first block
	def validate_block(info, line_number)
		error_msg = ""
		success = true

		# verifies the timestamps
		success, error_msg = validate_timestamps(info)
		return success, error_msg unless success

		if info['id'] != line_number
			error_msg = "Invalid block number #{info['id']}, should be #{line_number}"
			success = false
			return success, error_msg
		elsif info['prev_hash'].strip != @prev_hash.strip
			error_msg = "Previous hash was #{info['prev_hash']}, should be #{@prev_hash}"
			success = false
			return success, error_msg
		elsif not validate_hash(info)
			error_msg = "String #{info['original'].strip} hash set to #{info['self_hash'].strip}, should be #{get_hash(get_string_to_hash(info))}"
			success = false
			return success, error_msg
		else
			# updates the transaction logs
			success, error_msg = update_billcoins(info)
			#error_msg = "" unless not success
			return success, error_msg unless success
		end

		return success, error_msg
	end

	# prints how many billcoins each address has
	# excludes the system's billcoin count,
	# which is infinity
	def print_billcoins
		@billcoins.each_pair {|k, v| puts "#{k}: #{v} billcoins" unless k=="SYSTEM"}	# don't print SYSTEM billcoin count
	end

	# validates the block chain read from the 'path'
	# as a whole
	def validate_block_chain()
		# exits if file doesn't exist
		if not File.exist? @path
			puts 'The file does not exist, the program will exit' ; exit 
		end


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