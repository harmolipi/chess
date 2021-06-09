# frozen_string_literal: true

require_relative './piece'
require 'pry'

# Class for the pawn chess piece
class Pawn < Piece
  def initialize(color = 'WHITE', location = [0, 0])
    white_pawn = " \u2659 "
    black_pawn = " \u265F "
    super(white_pawn, black_pawn, color, location)
    @original_location = location
  end

  def move_to

  end

  def possible_moves
    movement_direction = @color.upcase == 'WHITE' ? 1 : -1
    possible_moves = [[@location[0], @location[1] + 1 * movement_direction]]
    possible_moves << [@location[0], @location[1] + 2 * movement_direction] if @location == @original_location
    possible_moves.select { |move| valid_move?(move) }
  end
end
