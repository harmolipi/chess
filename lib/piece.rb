# frozen_string_literal: true

require 'pry'

# General class for all pieces
class Piece
  attr_reader :location, :symbol

  def initialize(white_piece, black_piece, color, location)
    @symbol = color.upcase == 'WHITE' ? white_piece : black_piece
    @color = color
    @location = location
  end

  def to_s
    # need to investigate further, and see why this method doesn't seem
    # to matter in printing the chess board...
    binding.pry
    @symbol
  end

  def valid_move?(move)
    true # temp until we write this one out
    
  end
end
