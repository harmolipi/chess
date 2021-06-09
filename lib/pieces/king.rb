# frozen_string_literal: true

require_relative './piece'

# Class for the king chess piece
class King < Piece
  def initialize(color = 'WHITE', location = [0, 0])
    white_king = " \u2654 "
    black_king = " \u265A "
    super(white_king, black_king, color, location)
  end
end
