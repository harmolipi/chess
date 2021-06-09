# frozen_string_literal: true

require_relative './piece'

# Class for the queen chess piece
class Queen < Piece
  def initialize(color = 'WHITE', location = [0, 0])
    white_queen = " \u2655 "
    black_queen = " \u265B "
    super(white_queen, black_queen, color, location)
  end
end