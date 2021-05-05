# frozen_string_literal: true

# General class for all pieces
class Piece
  attr_reader :location, :symbol

  def initialize(symbol = 'X', location = [0, 0])
    @symbol = symbol
    @location = location
  end

  def to_s
    @symbol
  end
end
