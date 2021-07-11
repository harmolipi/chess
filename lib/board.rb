# frozen_string_literal: true

# rubocop: disable Metrics/AbcSize
# rubocop: disable Metrics/MethodLength
# rubocop: disable Metrics/ClassLength
# rubocop: disable Metrics/CyclomaticComplexity

require_relative './game'
require_relative './pieces/pawn'
require_relative './pieces/rook'
require_relative './pieces/knight'
require_relative './pieces/bishop'
require_relative './pieces/queen'
require_relative './pieces/king'
require_relative './colors'
require 'pry'
require 'msgpack'

# Class handling the chess board, its moves, and its contents
class Board
  attr_reader :board_contents, :white, :black
  attr_writer :current_player, :other_player

  POSSIBLE_MOVE = " \u25CF ".red
  VALID_COORDINATES = /^([A-H]|[a-h])[1-8]$/.freeze
  BLUE = 44
  MAGENTA = 45
  CYAN = 46
  GRAY = 47
  DARK_GRAY = 100
  LIGHT_RED = 101
  LIGHT_CYAN = 106

  # def initialize(board_contents = Array.new(8) { [] })
  def initialize
    normal_board = [
      {
        pawn1: Pawn.new('white', [0, 1]), pawn2: Pawn.new('white', [1, 1]), pawn3: Pawn.new('white', [2, 1]),
        pawn4: Pawn.new('white', [3, 1]), pawn5: Pawn.new('white', [4, 1]), pawn6: Pawn.new('white', [5, 1]),
        pawn7: Pawn.new('white', [6, 1]), pawn8: Pawn.new('white', [7, 1]), rook1: Rook.new('white', [0, 0]),
        rook2: Rook.new('white', [7, 0]), knight1: Knight.new('white', [1, 0]), knight2: Knight.new('white', [6, 0]),
        bishop1: Bishop.new('white', [2, 0]), bishop2: Bishop.new('white', [5, 0]), queen: Queen.new('white', [3, 0]),
        king: King.new('white', [4, 0])
      },
      {
        pawn1: Pawn.new('black', [0, 6]), pawn2: Pawn.new('black', [1, 6]), pawn3: Pawn.new('black', [2, 6]),
        pawn4: Pawn.new('black', [3, 6]), pawn5: Pawn.new('black', [4, 6]), pawn6: Pawn.new('black', [5, 6]),
        pawn7: Pawn.new('black', [6, 6]), pawn8: Pawn.new('black', [7, 6]), rook1: Rook.new('black', [0, 7]),
        rook2: Rook.new('black', [7, 7]), knight1: Knight.new('black', [1, 7]), knight2: Knight.new('black', [6, 7]),
        bishop1: Bishop.new('black', [2, 7]), bishop2: Bishop.new('black', [5, 7]), queen: Queen.new('black', [3, 7]),
        king: King.new('black', [4, 7])
      }
    ]

    almost_check = [
      {
        pawn1: Pawn.new('white', [2, 6]), pawn2: Pawn.new('white', [1, 1]), pawn3: Pawn.new('white', [2, 1]),
        pawn4: Pawn.new('white', [3, 1]), pawn5: Pawn.new('white', [4, 1]), pawn6: Pawn.new('white', [5, 1]),
        pawn7: Pawn.new('white', [6, 1]), pawn8: Pawn.new('white', [7, 1]), rook1: Rook.new('white', [0, 0]),
        rook2: Rook.new('white', [7, 0]), knight1: Knight.new('white', [1, 0]), knight2: Knight.new('white', [6, 0]),
        bishop1: Bishop.new('white', [2, 0]), bishop2: Bishop.new('white', [5, 0]), queen: Queen.new('white', [3, 0]),
        king: King.new('white', [4, 0])
      },
      {
        pawn1: Pawn.new('black', [0, 1]), pawn2: Pawn.new('black', [1, 6]), pawn3: Pawn.new('black', [2, 4]),
        pawn4: Pawn.new('black', [3, 6]), pawn5: Pawn.new('black', [4, 6]), pawn6: Pawn.new('black', [5, 6]),
        pawn7: Pawn.new('black', [6, 6]), pawn8: Pawn.new('black', [7, 6]), rook1: Rook.new('black', [0, 4]),
        rook2: Rook.new('black', [7, 7]), knight1: Knight.new('black', [1, 7]), knight2: Knight.new('black', [6, 7]),
        bishop1: Bishop.new('black', [2, 7]), bishop2: Bishop.new('black', [5, 7]), queen: Queen.new('black', [3, 7]),
        king: King.new('black', [4, 7])
      }
    ]

    checkmate_board1 = [
      {
        queen: Queen.new('white', [4, 5]), knight1: Knight.new('white', [3, 4])
      },
      {
        king: King.new('black', [4, 7])
      }
    ]

    checkmate_board2 = [
      {
        pawn1: Pawn.new('white', [4, 6]), pawn2: Pawn.new('white', [3, 4]), king: King.new('white', [4, 5])
      },
      {
        king: King.new('black', [4, 7])
      }
    ]

    checkmate_board3 = [
      {
        rook1: Rook.new('white', [3, 7]), rook2: Rook.new('white', [5, 4]), king: King.new('white', [4, 0])
      },
      {
        king: King.new('black', [7, 6]), pawn: Pawn.new('black', [1, 6])
      }
    ]

    @white = checkmate_board3[0]
    @black = checkmate_board3[1]
    @board_contents = Array.new(8) { Array.new(8) }
    @captured = []
    @last_move = nil
    @available_moves = []
    @available_attacks = []
    @current_player = 'white'
    @other_player = 'black'
    default_positions
  end

  def to_s(board_display = @board_contents, system_message = '', player = @current_player)
    # binding.pry
    system 'clear'
    puts "     -----  CURRENT TURN: #{player.upcase}  -----".green
    puts system_message
    puts "\n"
    row = 8
    board_display.each_with_index.reverse_each do |column, index|
      print "   #{row} "
      column.each_index do |index2|
        print square(index + index2, board_display[index2][index])
      end
      print "\n"
      row -= 1
    end
    puts '      a  b  c  d  e  f  g  h'
  end

  def square(index, contents)
    background = if @last_move == contents && !@last_move.nil?
                   MAGENTA # using 106 (light blue) for last move, and 42 (green) for current selection
                 else
                   index.odd? ? BLUE : CYAN # 47 = gray, 44 = blue
                 end
    square = contents.nil? ? '   ' : contents
    "\e[#{background}m#{square}\e[0m"
  end

  def get_piece(coordinates, board = @board_contents)
    board[coordinates[0]][coordinates[1]]
  end

  def display_possible_moves(piece, system_message = '')
    possible_moves_board = temp_board_array
    piece_square = possible_moves_board[piece.location[0]][piece.location[1]]
    possible_moves_board[piece.location[0]][piece.location[1]] = piece_square.symbol.on_green
    possible_moves_board = update_possible_moves(piece, possible_moves_board)
    to_s(possible_moves_board, system_message)
  end

  def update_possible_moves(piece, board = self)
    @available_moves = []
    piece.possible_moves.each do |direction|
      direction.each do |possible_move|
        break unless can_move?(piece, possible_move)

        @available_moves << possible_move
        board[possible_move[0]][possible_move[1]] = POSSIBLE_MOVE
      end
    end

    piece.possible_attacks.each do |direction|
      direction.each do |possible_attack|
        board_square = get_piece(possible_attack, board)
        break unless can_attack?(piece, possible_attack) && enemy_piece?(piece, board_square)

        @available_attacks << possible_attack
        board[possible_attack[0]][possible_attack[1]] = board_square.symbol.on_red
      end
    end
    board
  end

  def test_possible_check(piece, move, player = @current_player)
    # Check to see if a piece making this move would put the player in check

    temp_board = copy_board
    temp_other_player_piece = temp_board.get_piece(piece.location)
    temp_board.move(temp_other_player_piece, move)
    check?(temp_board, player)
  end

  def check?(chess_board = self, player = @other_player)
    # Checks whether the player's king is currently in check

    player_pieces = player == 'white' ? chess_board.white : chess_board.black
    other_player_pieces = player == 'white' ? chess_board.black : chess_board.white
    other_player_pieces.any? do |piece|
      other_player_pieces[piece[0]].possible_attacks.any? { |direction| direction.include?(player_pieces[:king].location) }
    end
  end

  def checkmate?(player = @other_player)
    # checks to see if given player is in checkmate

    player_pieces = player == 'white' ? @white : @black
    is_checkmate = true
    player_pieces.each do |piece|
      player_piece = player_pieces[piece[0]]
      player_piece.possible_moves.each do |direction|
        next if direction.empty?
        direction.each do |move|
          next if move.nil?

          unless test_possible_check(player_piece, move, player)
            is_checkmate = false
            break
          end
        end
        break unless is_checkmate
      end
      
      return is_checkmate unless is_checkmate

      player_piece.possible_attacks.each do |direction|
        next if direction.empty?
        direction.each do |attack|
          next if attack.nil?

          unless test_possible_check(player_piece, attack, player)
            is_checkmate = false
            break
          end
        end
        break unless is_checkmate
      end
      is_checkmate
    end
  end

  def stalemate?(player = @other_player)
    # Checks to see if player is in stalemate

    player_pieces = player == 'white' ? @white : @black
    player_pieces.none? do |piece|
      any_possible_moves?(player_pieces[piece[0]])
    end
  end

  def copy_board(chess_board = self)
    # binding.pry
    Marshal.load(Marshal.dump(chess_board))
  end

  def display_selection(selection)
    selection_board = temp_board_array

    board_square = selection_board[selection[0]][selection[1]]
    selection_board[selection[0]][selection[1]] = board_square.symbol.on_green

    to_s(selection_board)
  end

  def temp_board_array
    # copies @board_contents to a temporary local board array
    board_array = []
    # binding.pry
    @board_contents.each_with_index do |column, index|
      board_array << []
      column.each { |square| board_array[index] << square.dup }
    end
    # binding.pry
    board_array
  end

  def player_piece?(piece, player)
    piece.color == player
  end

  def enemy_piece?(piece, possible_enemy)
    # binding.pry
    return false if possible_enemy == POSSIBLE_MOVE

    piece.color != possible_enemy.color unless possible_enemy.nil?
  end

  def can_move?(piece, target)
    # binding.pry
    # move_board = temp_board_array
    target_piece = get_piece(target)
    # update_possible_moves(piece, move_board) # think this might be what's throwing off the board ***

    piece.possible_moves.any? { |direction| direction.include?(target) } && target_piece.nil? &&
      !test_possible_check(piece, target, @current_player)

    # false

    # piece.possible_moves.include?(target) && target_piece.nil?

    # @available_moves.include?(target) && target_piece.nil?
  end

  def can_attack?(piece, target)
    # binding.pry
    # target_piece = get_piece(target) ##
    # piece.possible_attacks.include?(target) && enemy_piece?(piece, target_piece)
    # @available_attacks.include?(target) ##
    piece.possible_attacks.any? do |direction|
      direction.any? do |attack|
        attack == target && enemy_piece?(piece, get_piece(target))
      end
    end
  end

  def move(piece, target_location)
    update_piece_location(piece, target_location)
  end

  def attack(piece, target_location)
    target_piece = get_piece(target_location)
    other_player_pieces = @other_player == 'black' ? @black : @white
    @captured << target_piece
    other_player_pieces.reject! { |_taken_piece_name, taken_piece| taken_piece == get_piece(target_location) }
    update_piece_location(piece, target_location)
  end

  def any_possible_moves?(piece)
    piece.possible_moves.any? do |direction|
      direction.any? do |move|
        can_move?(piece, move) || can_attack?(piece, move)
      end
    end
  end

  def update_piece_location(piece, target_location, chess_board = @board_contents)
    chess_board[piece.location[0]][piece.location[1]] = nil
    piece.location = target_location
    chess_board[target_location[0]][target_location[1]] = piece
  end

  def can_promote?(piece)
    piece.is_a?(Pawn) && ((@current_player == 'white' && piece.location[1] == 7) ||
    (@current_player == 'black' && piece.location[1].zero?))
  end

  def promote(piece, promotion)
    current_player_pieces = @current_player == 'white' ? @white : @black
    old_piece_key = current_player_pieces.find { |_key, value| value == piece }[0]
    new_piece = case promotion.downcase
                when 'queen'
                  # binding.pry
                  Queen.new(@current_player, piece.location)
                when 'rook'
                  Rook.new(@current_player, piece.location)
                when 'knight'
                  Knight.new(@current_player, piece.location)
                when 'bishop'
                  Bishop.new(@current_player, piece.location)
                when 'pawn'
                  piece
                end
    @current_player == 'white' ? @white[old_piece_key] = new_piece : @black[old_piece_key] = new_piece
    # need to correctly add promoted piece to player's pieces
    # binding.pry
    @last_move = new_piece
    update_piece_location(new_piece, piece.location)
  end

  def map_coordinates(coordinates)
    # converts chess coordinates to array coordinates
    [coordinates[0].downcase.codepoints[0] - 97, coordinates[1].to_i - 1]
  end

  def coordinates_input
    loop do
      print 'Enter your coordinates: '
      coordinates = gets.chomp
      return map_coordinates(coordinates) if valid_coordinates?(coordinates)

      puts 'Invalid entry, please try again.'.red
    end
  end

  def valid_coordinates?(coordinates)
    coordinates.match(VALID_COORDINATES)
  end

  def default_positions
    # @board_contents = [[@white[rook1], @white[pawn1], EMPTY_CELL, EMPTY_CELL,
    #                     EMPTY_CELL, EMPTY_CELL, @black[pawn1], @black[rook1]],
    #                   ]
    # commented while changing pieces to arrays
    @white.each_value do |piece|
      @board_contents[piece.location[0]][piece.location[1]] = piece
    end

    @black.each_value do |piece|
      @board_contents[piece.location[0]][piece.location[1]] = piece
    end

    # @white.each do |piece|
    #   @board_contents[piece.location[0]][piece.location[1]] = piece
    # end

    # @black.each do |piece|
    #   @board_contents[piece.location[0]][piece.location[1]] = piece
    # end
  end
end

# rubocop: enable Metrics/CyclomaticComplexity
# rubocop: enable Metrics/ClassLength
# rubocop: enable Metrics/MethodLength
# rubocop: enable Metrics/AbcSize
