# frozen_string_literal: true

require_relative './piece'

# Class for the bishop chess piece
class Bishop < Piece
  def initialize(color = 'WHITE', location = [0, 0])
    white_bishop = " \u2657 "
    black_bishop = " \u265D "
    super(white_bishop, black_bishop, color, location)
  end

  def possible_moves
    possible_moves = Array.new(4) { [] }
    location_col = @location[0]
    location_row = @location[1]
    1.upto(7) do |move|
      possible_moves[0] << [location_col + move, location_row + move]
    end

    1.upto(7) do |move|
      possible_moves[1] << [location_col + move, location_row - move]
    end

    1.upto(7) do |move|
      possible_moves[2] << [location_col - move, location_row - move]
    end

    1.upto(7) do |move|
      possible_moves[3] << [location_col - move, location_row + move]
    end

    possible_moves.each do |direction|
      direction.select! { |move| valid_move?(move) }
    end

    possible_moves
  end
end
