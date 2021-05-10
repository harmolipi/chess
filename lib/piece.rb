# frozen_string_literal: true

# General class for all pieces
class Piece
  attr_reader :location, :symbol

  def initialize(symbol = 'X', location = [0, 0])
    @symbol = symbol
    @location = location
  end

  def to_s
    # need to investigate further, and see why this method doesn't seem
    # to matter in printing the chess board...
    @symbol
  end

  def valid_move?(move)
    true # temp until we write this one out
  end
end
