require_relative 'Billcoin'

raise "Please only give a path to the file of block chains" unless ARGV.length == 1
bc = Billcoin.new ARGV[0]
bc.validate_block_chain

bc.print_billcoins