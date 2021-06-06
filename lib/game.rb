# frozen_string_literal: true

require_relative './board'
require_relative './pawn'
require 'pry'

my_pawn = Pawn.new('white', [0, 1])
other_pawn = Pawn.new('black', [0, 6])
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

# TO-DO: update #to_s_colored and #print_square in BOARD to identify and color squares that
#        can be attacked
