# frozen_string_literal: true

require 'yaml'

# General class for all pieces
class Piece
  attr_reader :symbol, :color
  attr_writer :board
  attr_accessor :location

  def initialize(white_piece, black_piece, color, location)
    @color = color
    @symbol = @color == 'white' ? white_piece : black_piece
    @location = location
  end

  def to_s
    @symbol
  end

  def valid_move?(move)
    move[0].between?(0, 7) && move[1].between?(0, 7)
  end

  def possible_attacks
    possible_moves
  end
end
