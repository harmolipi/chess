# frozen_string_literal: true

# rubocop: disable Metrics/AbcSize
# rubocop: disable Metrics/MethodLength
# rubocop: disable Metrics/ClassLength

require_relative './game'
require_relative './pieces/pawn'
require_relative './pieces/rook'
require_relative './pieces/knight'
require_relative './pieces/bishop'
require_relative './pieces/queen'
require_relative './pieces/king'
require_relative './colors'
require 'pry'

# Class handling the chess board, its moves, and its contents
class Board
  attr_reader :board_contents, :white
  attr_writer :current_player

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

    # temporary backup values:
    # @white = {
    #   pawn1: Pawn.new('white', [0, 1]), pawn2: Pawn.new('white', [1, 1]), pawn3: Pawn.new('white', [2, 1]),
    #   pawn4: Pawn.new('white', [3, 1]), pawn5: Pawn.new('white', [4, 1]), pawn6: Pawn.new('white', [5, 1]),
    #   pawn7: Pawn.new('white', [6, 1]), pawn8: Pawn.new('white', [7, 1]), rook1: Rook.new('white', [0, 0]),
    #   rook2: Rook.new('white', [7, 0]), knight1: Knight.new('white', [1, 0]), knight2: Knight.new('white', [6, 0]),
    #   bishop1: Bishop.new('white', [2, 0]), bishop2: Bishop.new('white', [5, 0]), queen: Queen.new('white', [3, 0]),
    #   king: King.new('white', [4, 0])
    # }
    # @black = {
    #   pawn1: Pawn.new('black', [0, 6]), pawn2: Pawn.new('black', [1, 6]), pawn3: Pawn.new('black', [2, 6]),
    #   pawn4: Pawn.new('black', [3, 6]), pawn5: Pawn.new('black', [4, 6]), pawn6: Pawn.new('black', [5, 6]),
    #   pawn7: Pawn.new('black', [6, 6]), pawn8: Pawn.new('black', [7, 6]), rook1: Rook.new('black', [0, 7]),
    #   rook2: Rook.new('black', [7, 7]), knight1: Knight.new('black', [1, 7]), knight2: Knight.new('black', [6, 7]),
    #   bishop1: Bishop.new('black', [2, 7]), bishop2: Bishop.new('black', [5, 7]), queen: Queen.new('black', [3, 7]),
    #   king: King.new('black', [4, 7])
    # }

    @white = {
      pawn1: Pawn.new('white', [0, 6]), pawn2: Pawn.new('white', [1, 1]), pawn3: Pawn.new('white', [2, 1]),
      pawn4: Pawn.new('white', [3, 1]), pawn5: Pawn.new('white', [4, 1]), pawn6: Pawn.new('white', [5, 1]),
      pawn7: Pawn.new('white', [6, 1]), pawn8: Pawn.new('white', [7, 1]), rook1: Rook.new('white', [0, 0]),
      rook2: Rook.new('white', [7, 0]), knight1: Knight.new('white', [1, 0]), knight2: Knight.new('white', [6, 0]),
      bishop1: Bishop.new('white', [2, 0]), bishop2: Bishop.new('white', [5, 0]), queen: Queen.new('white', [3, 0]),
      king: King.new('white', [4, 0])
    }
    @black = {
      pawn1: Pawn.new('black', [0, 1]), pawn2: Pawn.new('black', [1, 6]), pawn3: Pawn.new('black', [2, 6]),
      pawn4: Pawn.new('black', [3, 6]), pawn5: Pawn.new('black', [4, 6]), pawn6: Pawn.new('black', [5, 6]),
      pawn7: Pawn.new('black', [6, 6]), pawn8: Pawn.new('black', [7, 6]), rook1: Rook.new('black', [0, 4]),
      rook2: Rook.new('black', [7, 7]), knight1: Knight.new('black', [1, 7]), knight2: Knight.new('black', [6, 7]),
      bishop1: Bishop.new('black', [2, 7]), bishop2: Bishop.new('black', [5, 7]), queen: Queen.new('black', [3, 7]),
      king: King.new('black', [4, 7])
    }
    @board_contents = Array.new(8) { [] }
    @captured = []
    @last_move = nil
    @available_moves = []
    @available_attacks = []
    @current_player = 'white'
    default_positions
  end

  # def to_s(board_display = @board_contents)
  #   board_display.each_with_index.reverse_each do |column, index|
  #     print '   | '
  #     column.each_index do |index2|
  #       print board_display[index2][index].symbol || EMPTY_CELL
  #       print ' | '
  #     end
  #     print "\n"
  #   end
  # end

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
    # background = index.odd? ? 'on_gray' : 'on_blue'
    # binding.pry
    background = if @last_move == contents && !@last_move.nil?
                   MAGENTA # using 106 (light blue) for last move, and 42 (green) for current selection
                 else
                   index.odd? ? BLUE : CYAN # 47 = gray, 44 = blue
                 end
    square = contents.nil? ? '   ' : contents
    "\e[#{background}m#{square}\e[0m"
    # " #{square} ".send(background)
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

  def any_possible_moves?(coordinates)

  end

  def get_piece(coordinates, board = @board_contents)
    board[coordinates[0]][coordinates[1]]
  end

  def display_possible_moves(piece)
    # binding.pry
    possible_moves_board = temp_board
    @available_moves = []

    piece_square = possible_moves_board[piece.location[0]][piece.location[1]]
    possible_moves_board[piece.location[0]][piece.location[1]] = piece_square.symbol.on_green

    # piece.possible_moves.each do |possible_move|
    #   # board_square = possible_moves_board[possible_move[0]][possible_move[1]]
    #   board_square = get_piece(possible_move, possible_moves_board)
    #   if board_square.nil?
    #     possible_moves_board[possible_move[0]][possible_move[1]] = POSSIBLE_MOVE
    #   elsif enemy_piece?(piece, board_square)
    #     possible_moves_board[possible_move[0]][possible_move[1]] = board_square.symbol.on_red
    #   end
    # end

    # piece.possible_moves.each do |possible_move|
    #   # binding.pry
    #   # board_square = possible_moves_board[possible_move[0]][possible_move[1]]
    #   board_square = get_piece(possible_move, possible_moves_board)
    #   possible_moves_board[possible_move[0]][possible_move[1]] = POSSIBLE_MOVE if board_square.nil?
    # end

    # piece.possible_moves.each do |possible_move|
    #   # binding.pry
    #   board_square = get_piece(possible_move, possible_moves_board)
    #   break unless board_square.nil?

    #   possible_moves_board[possible_move[0]][possible_move[1]] = POSSIBLE_MOVE if board_square.nil?
    # end

    piece.possible_moves.each do |direction|
      direction.each do |possible_move|
        # binding.pry
        board_square = get_piece(possible_move, possible_moves_board)
        break unless board_square.nil?

        @available_moves << possible_move
        possible_moves_board[possible_move[0]][possible_move[1]] = POSSIBLE_MOVE
      end
    end

    piece.possible_attacks.each do |direction|
      direction.each do |possible_attack|
        # binding.pry
        board_square = get_piece(possible_attack, possible_moves_board)
        break if board_square.nil?

        if enemy_piece?(piece, board_square)
          @available_attacks << possible_attack
          possible_moves_board[possible_attack[0]][possible_attack[1]] = board_square.symbol.on_red
          break
        end
      end
    end

    # piece.possible_attacks.each do |possible_attack|
    #   board_square = get_piece(possible_attack, possible_moves_board)

    #   if enemy_piece?(piece, board_square)
    #     possible_moves_board[possible_attack[0]][possible_attack[1]] = board_square.symbol.on_red
    #   end
    # end

    to_s(possible_moves_board)
  end

  def display_selection(selection)
    selection_board = temp_board

    board_square = selection_board[selection[0]][selection[1]]
    selection_board[selection[0]][selection[1]] = board_square.symbol.on_green

    to_s(selection_board)
  end

  def temp_board
    # copies @board_contents to a temporary local board array
    temp_board_array = []
    @board_contents.each_with_index do |column, index|
      temp_board_array << []
      column.each { |square| temp_board_array[index] << square }
    end
    temp_board_array
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
    target_piece = get_piece(target)
    # piece.possible_moves.include?(target) && target_piece.nil?
    @available_moves.include?(target) && target_piece.nil?
  end

  def can_attack?(piece, target)
    # binding.pry
    target_piece = get_piece(target)
    # piece.possible_attacks.include?(target) && enemy_piece?(piece, target_piece)
    @available_attacks.include?(target)
  end

  def move(piece, target_location)
    target_piece = get_piece(target_location)
    if can_move?(piece, target_location)
      # @board_contents[piece.location[0]][piece.location[1]] = nil
      # piece.location = target_location
      # @board_contents[target_location[0]][target_location[1]] = piece
      update_piece_location(piece, target_location)
    elsif can_attack?(piece, target_location)
      # @board_contents[piece.location[0]][piece.location[1]] = nil
      # piece.location = target_location
      other_player_pieces = @current_player == 'white' ? @black : @white
      @captured << target_piece
      other_player_pieces.reject! { |_taken_piece_name, taken_piece| taken_piece == get_piece(target_location) }
      # @board_contents[target_location[0]][target_location[1]] = piece
      update_piece_location(piece, target_location)
    end
    @last_move = piece
  end

  def update_piece_location(piece, target_location)
    @board_contents[piece.location[0]][piece.location[1]] = nil
    piece.location = target_location
    @board_contents[target_location[0]][target_location[1]] = piece
  end

  def can_promote?(piece)
    piece.is_a?(Pawn) && ((@current_player == 'white' && piece.location[1] == 7) ||
    (@current_player == 'black' && piece.location[1].zero?))
  end

  def promote(piece, promotion)
    new_piece = case promotion.downcase
                when 'queen'
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
    @white.each_value do |piece|
      @board_contents[piece.location[0]][piece.location[1]] = piece
    end

    @black.each_value do |piece|
      @board_contents[piece.location[0]][piece.location[1]] = piece
    end
  end
end

# rubocop: enable Metrics/ClassLength
# rubocop: enable Metrics/MethodLength
# rubocop: enable Metrics/AbcSize
