# frozen_string_literal: true

# rubocop: disable Metrics/AbcSize
# rubocop: disable Metrics/MethodLength

require_relative './pawn'
require_relative './rook'
require_relative './knight'
require_relative './bishop'
require_relative './queen'
require_relative './king'
require_relative './colors'
require 'pry'

# Class handling the chess board, its moves, and its contents
class Board
  attr_reader :board_contents

  POSSIBLE_MOVE = " \u25CF ".red

  # def initialize(board_contents = Array.new(8) { [] })
  def initialize
    @white = {
      pawn1: Pawn.new('white', [0, 1]), pawn2: Pawn.new('white', [1, 1]), pawn3: Pawn.new('white', [2, 1]),
      pawn4: Pawn.new('white', [3, 1]), pawn5: Pawn.new('white', [4, 1]), pawn6: Pawn.new('white', [5, 1]),
      pawn7: Pawn.new('white', [6, 1]), pawn8: Pawn.new('white', [7, 1]), rook1: Rook.new('white', [0, 0]),
      rook2: Rook.new('white', [7, 0]), knight1: Knight.new('white', [1, 0]), knight2: Knight.new('white', [6, 0]),
      bishop1: Bishop.new('white', [2, 0]), bishop2: Bishop.new('white', [5, 0]), queen: Queen.new('white', [3, 0]),
      king: King.new('white', [4, 0])
    }
    @black = {
      pawn1: Pawn.new('black', [0, 6]), pawn2: Pawn.new('black', [1, 6]), pawn3: Pawn.new('black', [2, 6]),
      pawn4: Pawn.new('black', [3, 6]), pawn5: Pawn.new('black', [4, 6]), pawn6: Pawn.new('black', [5, 6]),
      pawn7: Pawn.new('black', [6, 6]), pawn8: Pawn.new('black', [7, 6]), rook1: Rook.new('black', [0, 7]),
      rook2: Rook.new('black', [7, 7]), knight1: Knight.new('black', [1, 7]), knight2: Knight.new('black', [6, 7]),
      bishop1: Bishop.new('black', [2, 7]), bishop2: Bishop.new('black', [5, 7]), queen: Queen.new('black', [3, 7]),
      king: King.new('black', [4, 7])
    }
    @board_contents = Array.new(8) { [] }
    default_positions
  end

  def to_s(board_display = @board_contents)
    board_display.each_with_index.reverse_each do |column, index|
      print '   | '
      column.each_index do |index2|
        print board_display[index2][index].symbol || EMPTY_CELL
        print ' | '
      end
      print "\n"
    end
  end

  def to_s_colored(board_display = @board_contents)
    # binding.pry
    board_display.each_with_index.reverse_each do |column, index|
      print '   '
      column.each_index do |index2|
        print print_square(index + index2, board_display[index2][index])
      end
      print "\n"
    end
  end

  def print_square(index, contents)
    # background = index.odd? ? 'on_gray' : 'on_blue'
    background = index.odd? ? 47 : 44
    square = contents.nil? ? '   ' : contents
    "\e[#{background}m#{square}\e[0m"
    # " #{square} ".send(background)
  end

  def display_selection

  end

  # def display_possible_moves(piece)
  #   possible_moves_board = @board_contents
  #   piece.possible_moves.each do |possible_move|
  #     board_square = possible_moves_board[possible_move[0]][possible_move[1]]
  #     if board_square.nil?
  #       possible_moves_board[possible_move[0]][possible_move[1]] = EMPTY_CELL.red
  #     end
  #   end
  #   to_s(possible_moves_board)
  # end

  def display_possible_moves(piece)
    possible_moves_board = []

    # copies @board_contents to a temporary local board array (maybe move to new method?)
    @board_contents.each_with_index do |column, index|
      possible_moves_board << []
      column.each { |square| possible_moves_board[index] << square }
    end

    piece.possible_moves.each do |possible_move|
      board_square = possible_moves_board[possible_move[0]][possible_move[1]]
      # possible_moves_board[possible_move[0]][possible_move[1]] = POSSIBLE_MOVE if board_square.nil?
      # binding.pry
      if board_square.nil?
        possible_moves_board[possible_move[0]][possible_move[1]] = POSSIBLE_MOVE
      elsif enemy_piece?(piece, possible_moves_board[possible_move[0]][possible_move[1]])
        possible_moves_board[possible_move[0]][possible_move[1]] = possible_moves_board[possible_move[0]][possible_move[1]].symbol.on_red
      end
    end

    to_s_colored(possible_moves_board)
  end

  def enemy_piece?(piece, possible_enemy)
    piece.color != possible_enemy.color
  end

  def can_move?(piece, location)
    piece.possible_moves.include?(location) && (@board_contents[location[0]][location[1]].nil? ||
                                               enemy_piece?(piece, @board_contents[location[0]][location[1]]))
  end

  def move(piece, location)
    piece.location = location if can_move?(piece, location)
  end

  def to_s_temp
    temp_array = [['1', '2', '3', '4', '5', '6', '7', '8'], ['1', '2', '3', '4', '5', '6', '7', '8'], ['1', '2', '3', '4', '5', '6', '7', '8'], ['1', '2', '3', '4', '5', '6', '7', '8'], ['1', '2', '3', '4', '5', '6', '7', '8'], ['1', '2', '3', '4', '5', '6', '7', '8'], ['1', '2', '3', '4', '5', '6', '7', '8'], ['1', '2', '3', '4', '5', '6', '7', '8']]
    temp_array.each_index.reverse_each do |x|
      temp_array[x].each do |y|
        print "| #{y}"
      end
      puts "\n"
    end

    temp_array[2][2] = 'x'

    puts "\n\n"
    temp_array.each_index.reverse_each do |x|
      temp_array[x].each do |y|
        print "| #{y} "
      end
      puts "|\n"
    end
  end

  def default_positions
    # @board_contents = [[@white[rook1], @white[pawn1], EMPTY_CELL, EMPTY_CELL,
    #                     EMPTY_CELL, EMPTY_CELL, @black[pawn1], @black[rook1]],
    #                   ]
    @white.each_value do |piece|
      @board_contents[piece.location[0]][piece.location[1]] = piece
    end

    @black.each_value do |piece|
      @board_contents[piece.location[0]][piece.location[1]] = piece
    end
  end
end

# rubocop: enable Metrics/MethodLength
# rubocop: enable Metrics/AbcSize
