require_relative 'Billcoin'

if ARGV.length != 1
	puts "Please only give a path to the file of block chains"
	exit
end

# need to validate if the file exists

bc = Billcoin.new ARGV[0]
bc.validate_block_chain

bc.print_billcoins