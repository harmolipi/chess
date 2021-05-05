# frozen_string_literal: true

# General class for all pieces
class Piece
  def initialize(symbol = 'X')
    @symbol = symbol
  end

  def to_s
    @symbol
  end
end
