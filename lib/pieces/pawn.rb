# frozen_string_literal: true

# rubocop: disable Metrics/AbcSize

require_relative './piece'
require 'pry'

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
    # binding.pry unless en_passant.nil?
    possible_attacks = Array.new(3) { [] }
    possible_attacks[0] << [@location[0] - 1, @location[1] + 1 * @movement_direction]
    # possible_attacks[1] << [en_passant.location[0], en_passant.location[1] + 1 * @movement_direction] unless en_passant.nil?
    possible_attacks[2] << [@location[0] + 1, @location[1] + 1 * @movement_direction]
    possible_attacks[0].select! { |move| valid_move?(move) }
    possible_attacks[2].select! { |move| valid_move?(move) }
    possible_attacks
  end

  # def en_passant
  #   # returns en-passant attack location if en-passant is possible
  #   # else returns nil

  #   binding.pry
  #   puts 'hi'
  #   [0, 0]
  # end

  def en_passant2
    # returns en-passant attack location if en-passant is possible
    # else returns nil

    # check if en-passant is possible
    binding.pry
    if @color == 'white'
      if @location[1] == 4
        if @board.get_piece_at([@location[0], @location[1] - 2]).nil?
          return [@location[0], @location[1] - 2]
        end
      end
    else
      if @location[1] == 3
        if @board.get_piece_at([@location[0], @location[1] + 2]).nil?
          return [@location[0], @location[1] + 2]
        end
      end
    end
    nil
  end
end

# rubocop: enable Metrics/AbcSize
