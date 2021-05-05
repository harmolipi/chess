# frozen_string_literal: true

# rubocop: disable Metrics/AbcSize

require_relative './pawn'
require_relative './rook'
require_relative './knight'
require_relative './bishop'
require_relative './queen'
require_relative './king'

# Class handling the chess board, its moves, and its contents
class Board

  EMPTY_CELL = '.'

  def initialize(board_contents = Array.new(8) { [] })
    @board_contents = board_contents
    @white = { pawn1: Pawn.new, pawn2: Pawn.new, pawn3: Pawn.new, pawn4: Pawn.new,
               pawn5: Pawn.new, pawn6: Pawn.new, pawn7: Pawn.new, pawn8: Pawn.new,
               rook1: Rook.new, rook2: Rook.new, knight1: Knight.new, knight2: Knight.new,
               bishop1: Bishop.new, bishop2: Bishop.new, queen: Queen.new, king: King.new }
    @black = { pawn1: Pawn.new, pawn2: Pawn.new, pawn3: Pawn.new, pawn4: Pawn.new,
               pawn5: Pawn.new, pawn6: Pawn.new, pawn7: Pawn.new, pawn8: Pawn.new,
               rook1: Rook.new, rook2: Rook.new, knight1: Knight.new, knight2: Knight.new,
               bishop1: Bishop.new, bishop2: Bishop.new, queen: Queen.new, king: King.new }
  end

  def to_s

  end

  def default_positions
    @board_contents = [[@white[rook1], @white[pawn1], EMPTY_CELL, EMPTY_CELL,
                        EMPTY_CELL, EMPTY_CELL, @black[pawn1], @black[rook1]],
                      ]
  end
end

# rubocop: enable Metrics/AbcSize
