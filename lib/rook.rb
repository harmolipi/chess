# frozen_string_literal: true

require_relative './piece'

# Class for the rook chess piece
class Rook < Piece
  def initialize(color = 'WHITE', location = [0, 0])
    white_rook = " \u2656 "
    black_rook = " \u265C "
    super(white_rook, black_rook, color, location)
  end
end
