# frozen_string_literal: true

require_relative './piece'

# Class for the queen chess piece
class Queen < Piece
  def initialize(color = 'WHITE', location = [0, 0])
    white_queen = " \u2655 "
    black_queen = " \u265B "
    super(white_queen, black_queen, color, location)
  end

  def possible_moves
    possible_moves = Array.new(8) { [] }
    location_col = @location[0]
    location_row = @location[1]

    1.upto(7) do |move|
      possible_moves[0] << [location_col, location_row + move]
    end

    1.upto(7) do |move|
      possible_moves[1] << [location_col + move, location_row + move]
    end

    1.upto(7) do |move|
      possible_moves[2] << [location_col + move, location_row]
    end

    1.upto(7) do |move|
      possible_moves[3] << [location_col + move, location_row - move]
    end

    1.upto(7) do |move|
      possible_moves[4] << [location_col, location_row - move]
    end

    1.upto(7) do |move|
      possible_moves[5] << [location_col - move, location_row - move]
    end

    1.upto(7) do |move|
      possible_moves[6] << [location_col - move, location_row]
    end

    1.upto(7) do |move|
      possible_moves[7] << [location_col - move, location_row + move]
    end

    possible_moves.each do |direction|
      direction.select! { |move| valid_move?(move) }
    end

    possible_moves
  end
end
