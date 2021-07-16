# frozen_string_literal: true

require_relative './piece'

# Class for the king chess piece
class King < Piece
  attr_reader :has_moved

  def initialize(color = 'WHITE', location = [0, 0], has_moved = false)
    white_king = " \u2654 "
    black_king = " \u265A "
    super(white_king, black_king, color, location)
    @original_location = location
    @has_moved = has_moved
  end

  def possible_moves
    possible_moves = Array.new(9) { [] }
    location_col = @location[0]
    location_row = @location[1]

    possible_moves[0] << [location_col, location_row + 1]
    possible_moves[1] << [location_col + 1, location_row + 1]
    possible_moves[2] << [location_col + 1, location_row]
    possible_moves[3] << [location_col + 1, location_row - 1]
    possible_moves[4] << [location_col, location_row - 1]
    possible_moves[5] << [location_col - 1, location_row - 1]
    possible_moves[6] << [location_col - 1, location_row]
    possible_moves[7] << [location_col - 1, location_row + 1]

    possible_moves.each do |direction|
      direction.select! { |move| valid_move?(move) }
    end

    possible_moves
  end

  def update_has_moved
    @has_moved = true if @location != @original_location
  end
end
