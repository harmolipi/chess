# frozen_string_literal: true

require_relative './piece'

# Class for the knight chess piece
class Knight < Piece
  def initialize(color = 'WHITE', location = [0, 0])
    white_knight = " \u2658 "
    black_knight = " \u265E "
    super(white_knight, black_knight, color, location)
  end
end