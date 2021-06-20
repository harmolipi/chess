# frozen_string_literal: true

# rubocop: disable Metrics/AbcSize

require_relative './piece'
require 'pry'

# Class for the pawn chess piece
class Pawn < Piece
  def initialize(color = 'WHITE', location = [0, 0])
    white_pawn = " \u2659 "
    black_pawn = " \u265F "
    super(white_pawn, black_pawn, color, location)
    @original_location = location
    @movement_direction = @color == 'white' ? 1 : -1
  end

  def possible_moves
    # binding.pry
    possible_moves = []
    possible_moves << [[@location[0], @location[1] + 1 * @movement_direction]]
    possible_moves[0] << [@location[0], @location[1] + 2 * @movement_direction] if @location == @original_location
    possible_moves[0].select! { |move| valid_move?(move) }
    possible_moves
  end

  # def possible_moves
  #   possible_moves = [[@location[0], @location[1] + 1 * @movement_direction]]
  #   possible_moves << [@location[0], @location[1] + 2 * @movement_direction] if @location == @original_location
  #   possible_moves.select! { |move| valid_move?(move) }

  #   possible_moves = []
  #   current_square = @location
  #   loop do
  #     next_square = [current_square[0], current_square[1] + 1 * @movement_direction]

  #   end
  # end

  def possible_attacks
    possible_attacks = []
    possible_attacks << [@location[0] - 1, @location[1] + 1 * @movement_direction]
    possible_attacks << [@location[0] + 1, @location[1] + 1 * @movement_direction]
    possible_attacks.select { |move| valid_move?(move) }
  end
end

# rubocop: enable Metrics/AbcSize
