# frozen_string_literal: true

require_relative './board'
require_relative './pieces/pawn'
require 'pry'

my_pawn = Pawn.new('white', [0, 1])
# other_pawn = Pawn.new('black', [0, 6])
# p my_pawn.location
# puts my_pawn.symbol
my_board = Board.new
my_board.to_s_colored
# my_board.print_square(1, my_pawn)
puts "\n"
my_board.display_possible_moves(my_pawn)
# my_board.display_possible_moves(other_pawn)
puts "\n"
my_board.to_s_colored
puts my_board.can_move?(my_pawn, [0, 3])
# p my_board.coordinates_input
my_move = my_board.coordinates_input
my_board.move(my_board.white[:pawn1], my_move)
my_board.to_s_colored
