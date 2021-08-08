# frozen_string_literal: true

require_relative './piece'

# Class for the pawn chess piece
class Pawn < Piece
  attr_reader :movement_direction

  def initialize(color = 'white', location = [0, 0])
    white_pawn = " \u2659 "
    black_pawn = " \u265F "
    super(white_pawn, black_pawn, color, location)
    @original_location = location
    @movement_direction = @color == 'white' ? 1 : -1
  end

  def possible_moves
    possible_moves = []
    possible_moves << [[@location[0], @location[1] + 1 * @movement_direction]]
    possible_moves[0] << [@location[0], @location[1] + 2 * @movement_direction] if @location == @original_location
    possible_moves[0].select! { |move| valid_move?(move) }
    possible_moves
  end

  def possible_attacks
    possible_attacks = Array.new(3) { [] }
    possible_attacks[0] << [@location[0] - 1, @location[1] + 1 * @movement_direction]
    possible_attacks[2] << [@location[0] + 1, @location[1] + 1 * @movement_direction]
    possible_attacks[0].select! { |move| valid_move?(move) }
    possible_attacks[2].select! { |move| valid_move?(move) }
    possible_attacks
  end
end
