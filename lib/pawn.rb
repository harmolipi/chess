# frozen_string_literal: true

require_relative './piece'

# Class for the pawn chess piece
class Pawn < Piece
  # def initialize(start_location, current_location = start_location, piece_number, color)
  def initialize()
    # @start_location = start_location
    # @current_location = current_location
    # @piece_number = piece_number
    super
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

  def move_to

  end

  def valid_move?

  end
end
