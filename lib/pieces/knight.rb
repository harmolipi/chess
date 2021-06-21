# frozen_string_literal: true

require_relative './piece'

# Class for the knight chess piece
class Knight < Piece
  def initialize(color = 'WHITE', location = [0, 0])
    white_knight = " \u2658 "
    black_knight = " \u265E "
    super(white_knight, black_knight, color, location)
  end

  def possible_moves
    possible_moves = Array.new(8) { [] }
    location_col = @location[0]
    location_row = @location[1]

    possible_moves[0] << [location_col + 1, location_row + 2]
    possible_moves[1] << [location_col + 2, location_row + 1]
    possible_moves[2] << [location_col + 2, location_row - 1]
    possible_moves[3] << [location_col + 1, location_row - 2]
    possible_moves[4] << [location_col - 1, location_row - 2]
    possible_moves[5] << [location_col - 2, location_row - 1]
    possible_moves[6] << [location_col - 2, location_row + 1]
    possible_moves[7] << [location_col - 1, location_row + 2]

    possible_moves.each do |direction|
      direction.select! { |move| valid_move?(move) }
    end

    possible_moves
  end
end
