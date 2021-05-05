# frozen_string_literal: true

require_relative './piece'

# Class for the pawn chess piece
class Pawn < Piece
  # def initialize(start_location, current_location = start_location, piece_number, color)
  def initialize(color = 'WHITE', location = [0, 0])
    white_pawn = "\u2654"
    black_pawn = "\u265A"
    super(color.upcase == 'WHITE' ? white_pawn : black_pawn, location)
    @location = location
    @moved = false
    # @color = color
    # @possible_moves = possible_moves
  end

  def possible_moves
    if @start_location == @current_location
      puts 'starting point'
    else
      puts 'elsewhere'
    end
  end

  def to_s
    @symbol
  end

  def move_to

  end

  def valid_move?

  end
end
