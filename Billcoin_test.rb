require 'minitest/autorun'

require_relative 'Billcoin'

class Billcoin_test < Minitest::Test
	# a simple setup for creating an instance of Billcoin
	def setup
		@bc = Billcoin.new 'dummy_file'
	end

	# tests the newly created instance is not nil
	def test_new_billcoin_not_nil
		refute_nil @bc
	end

	# tests if object created correctly
	def test_billcoin_is_billcoin
		assert @bc.is_a?(Billcoin)
	end

	# UNIT TESTS FOR METHOD get_hash()

	def test_get_hash_test_string
		assert_equal @bc.get_hash('test'), 'f3f2' 
	end

	# EDGE CASE
	# where the passed in string is empty
	def test_get_hash_empty_string
		assert_equal @bc.get_hash(''), '0' 
	end


	# UNIT TESTS FOR METHOD parse_info()

	def test_parse_info_block_number
		info = @bc.parse_info '123456|test_prev_hash|test_transaction|test_timestamp|test_hash'
		assert_equal info['id'], 123456
	end

	def test_parse_info_prev_hash
		info = @bc.parse_info 'test_block_num|8d96|test_transaction|test_timestamp|test_hash'
		assert_equal info['prev_hash'], '8d96'
	end


	def test_parse_info_transactions
		info = @bc.parse_info 'test_block_num|test_prev_hash|tt1:tt2:tt3|test_timestamp|test_hash'
		assert_equal info['transaction'].length, 3
	end


	def test_parse_info_timestamp
		info = @bc.parse_info 'test_block_num|test_prev_hash|test_transaction|15000000000.6598754|test_hash'
		assert_equal info['ts'][:sec], 15000000000
		assert_equal info['ts'][:nsec], 6598754
	end

	def test_parse_info_hash
		info = @bc.parse_info 'test_block_num|test_prev_hash|test_transaction|test_timestamp|fd15'
		assert_equal info['self_hash'], 'fd15'
	end

	def test_parse_info_original
		info = @bc.parse_info 'test_block_num|test_prev_hash|test_transaction|test_timestamp|test_hash'
		assert_equal info['original'], 'test_block_num|test_prev_hash|test_transaction|test_timestamp|test_hash'
	end


	# UNIT TEST FOR METHOD get_string_to_hash()

	def test_get_string_to_hash
		info = @bc.parse_info '0|test_prev_hash|test_transaction|0.0|test_hash'
		assert_equal @bc.get_string_to_hash(info), '0|test_prev_hash|test_transaction|0.0'
	end


	# UNIT TESTS FOR METHOD validate_address()

	def test_validate_address_valid
		address = 'abc'
		s, e = @bc.validate_address address
		assert_equal s, true
		assert_equal e, ''
	end

	def test_validate_address_not_alphabetic
		address = 'ab666'
		s, e = @bc.validate_address address
		assert_equal s, false
		assert_equal e, "The address #{address} is not alphabetic."
	end

	def test_validate_address_too_long
		address = 'abccccccccc'
		s, e = @bc.validate_address address
		assert_equal s, false
		assert_equal e, "Invalid address length for #{address}, should be at most 6 alphabetic characters."
	end


	# UNIT TESTS FOR METHOD validate_billcoins()

	def test_validate_billcoins_normal
		@bc.billcoins['user1'] = 500
		s, e = @bc.validate_billcoins 'user1'
		assert_equal s, true
		assert_equal e, ''
	end

	def test_validate_billcoins_no_such_address
		@bc.billcoins['user1'] = 500
		s, e = @bc.validate_billcoins 'user2'
		assert_equal s, false
		assert_equal e, "Internal Error: user2 does not exist in the billcoin dictionary"
	end

	def test_validate_billcoins_negative
		@bc.billcoins['user1'] = -500
		s, e = @bc.validate_billcoins 'user1'
		assert_equal s, false
		assert_equal e, "Invalid block, address user1 has -500 billcoins!"
	end


	# UNIT TESTS FOR METHOD validate_timestamps()

	def test_validate_timestamps_true
		info = {'ts'=>{'sec': 50, 'nsec':-1}}
		s,e = @bc.validate_timestamps info
		assert_equal s, true
	end

	def test_validate_timestamps_false
		info = {'ts'=>{'sec': -1, 'nsec':-1}}
		s,e = @bc.validate_timestamps info
		assert_equal s, false
	end


	# UNIT TESTS FOR METHOD validate_hash()

	def test_validate_hash_true
		info = @bc.parse_info '0|test_prev_hash|test_transaction|0.0|b325'
		s,e = @bc.validate_hash info
		assert_equal s, true
	end

	def test_validate_hash_false
		info = @bc.parse_info 'test_block_num|test_prev_hash|test_transaction|test_timestamp|l33t'
		s,e = @bc.validate_hash info
		assert_equal s, false
	end


	# UNIT TESTS FOR METHOD validate_first_block()

	def test_validate_first_block
		info = @bc.parse_info '0|0|SYSTEM>Gaozu(100)|1518893687.329767000|fd18'
		s,e = @bc.validate_first_block info
		assert_equal s, true
	end


	# UNIT TESTS FOR METHOD validate_block()

	def test_validate_block
		info = @bc.parse_info '0|0|SYSTEM>Gaozu(100)|1518893687.329767000|fd18'
		s,e = @bc.validate_block info, 0
		assert_equal s, true
	end

	def test_validate_block_unsuccessful

		#def @bc.parse_info; "test"; end
		def @bc.validate_timestamps(info); false;"error"; end

		s,e = @bc.validate_block "test", 0
		assert_equal "Invalid block number , should be 0", e

	end

	#test that timestamp is validated, hash is validated, and billcoins are updated
	def test_validate_block_mock

	end







	# #UNIT TESTS FOR METHOD print_bill_coins

	# def test_correct_billcoins
	# 	@bc.billcoins['test_address'] = '1234'
	# 	assert_output(stdout = "test_address: 1234 billcoins\n"){@bc.print_billcoins}	
	# end

	# #UNIT TESTS FOR update_billcoins
	# def test_empty_transactions
	# 	bcmock = Minitest::Mock::new

	# end

	#UNIT TESTS FOR METHOD validate_block_chain

	# def test_bad_path
	# 	assert_raises(SystemExit){ @bc.validate_block_chain }
	# end

	# def test_bad_path2
	# 	def File.exists?; true; end
	# 	assert_raises(SystemExit){ @bc.validate_block_chain }
	# end




end