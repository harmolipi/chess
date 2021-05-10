# frozen_string_literal: true

require_relative './piece'

# Class for the pawn chess piece
class Pawn < Piece
  def initialize(color = 'WHITE', location = [0, 0])
    white_pawn = " \u2659 "
    black_pawn = " \u265F "
    super(color.upcase == 'WHITE' ? white_pawn : black_pawn, location)
    @location = location
    @original_location = location
    # @moved = false
    # @possible_moves = []
  end

  def move_to

  end

  def possible_moves
    possible_moves = [[@location[0], @location[1] + 1]]
    possible_moves << [@location[0], @location[1] + 2] if @location == @original_location
    possible_moves.select { |move| valid_move?(move) }
  end
end
