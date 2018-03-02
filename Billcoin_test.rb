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

	def test_validate_timestamps

	end


	# UNIT TESTS FOR METHOD validate_hash()

	def test_validate_hash

	end


	# UNIT TESTS FOR METHOD validate_first_block()

	def test_validate_first_block

	end


	# UNIT TESTS FOR METHOD validate_block()

	def test_validate_block

	end

end