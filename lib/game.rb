# frozen_string_literal: true

require_relative './board'
require_relative './pawn'

my_pawn = Pawn.new('black', [0, 1])
# p my_pawn.location
# puts my_pawn.symbol
my_board = Board.new
my_board.to_s_colored
# my_board.print_square(1, my_pawn)
puts "\n"
my_board.display_possible_moves(my_pawn)
