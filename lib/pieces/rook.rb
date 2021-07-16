# frozen_string_literal: true

require_relative './piece'

# Class for the rook chess piece
class Rook < Piece
  attr_reader :has_moved

  def initialize(color = 'WHITE', location = [0, 0], has_moved = false)
    white_rook = " \u2656 "
    black_rook = " \u265C "
    super(white_rook, black_rook, color, location)
    @original_location = location
    @has_moved = has_moved
  end

  def possible_moves
    possible_moves = Array.new(4) { [] }
    location_col = @location[0]
    location_row = @location[1]
    1.upto(7) do |move|
      possible_moves[0] << [location_col, location_row + move]
    end

    1.upto(7) do |move|
      possible_moves[1] << [location_col + move, location_row]
    end

    1.upto(7) do |move|
      possible_moves[2] << [location_col, location_row - move]
    end

    1.upto(7) do |move|
      possible_moves[3] << [location_col - move, location_row]
    end

    possible_moves.each do |direction|
      direction.select! { |move| valid_move?(move) }
    end

    possible_moves
  end

  def update_has_moved
    @has_moved = true if @location != @original_location
  end
end
