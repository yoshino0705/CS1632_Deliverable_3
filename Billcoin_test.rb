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
		assert_equals @bc.get_hash('test'), 'f3f2' 
	end

	# EDGE CASE
	# where the passed in string is empty
	def test_get_hash_empty_string
		assert_equals @bc.get_hash(''), '0' 
	end

	# UNIT TESTS FOR METHOD parse_info()

	# UNIT TESTS FOR METHOD get_string_to_hash()

	# UNIT TESTS FOR METHOD validate_address()

	# UNIT TESTS FOR METHOD update_billcoins()

	# UNIT TESTS FOR METHOD validate_timestamps()

	# UNIT TESTS FOR METHOD validate_hash()

	# UNIT TESTS FOR METHOD validate_first_block()

	# UNIT TESTS FOR METHOD validate_block()

	# UNIT TESTS FOR METHOD print_billcoins()

	# UNIT TESTS FOR METHOD validate_block_chain()

end