# frozen_string_literal: true

require_relative './piece'

# Class for the bishop chess piece
class Bishop < Piece
  def initialize(color = 'WHITE', location = [0, 0])
    white_bishop = " \u2657 "
    black_bishop = " \u265D "
    super(white_bishop, black_bishop, color, location)
  end
end
