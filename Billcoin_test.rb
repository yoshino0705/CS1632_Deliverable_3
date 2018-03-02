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

	def test_parse_info

	end

	# UNIT TESTS FOR METHOD get_string_to_hash()

	def test_get_string_to_hash

	end

	# UNIT TESTS FOR METHOD validate_address()

	def test_validate_address

	end

	# UNIT TESTS FOR METHOD update_billcoins()

	def test_update_billcoins

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

	# UNIT TESTS FOR METHOD print_billcoins()

	def test_print_billcoins

	end

	# UNIT TESTS FOR METHOD validate_block_chain()

	def test_validate_block_chain

	end

end