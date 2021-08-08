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
require 'pry-byebug'

# Class handling the chess board, its moves, and its contents
class Board

  attr_reader :board_contents, :white, :black, :last_move, :last_double_step, :available_moves, :available_attacks
  attr_accessor :current_player, :other_player

  POSSIBLE_MOVE = " \u25CF ".red
  VALID_COORDINATES = /^([A-H]|[a-h])[1-8]$/.freeze
  BLUE = 44
  MAGENTA = 45
  CYAN = 46
  GRAY = 47
  DARK_GRAY = 100
  LIGHT_RED = 101
  LIGHT_CYAN = 106
  DEFAULT_BOARD = [
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
  ].freeze
  DEFAULT_CHESS_HASH = { '@board_contents' => Array.new(8) { Array.new(8) }, '@white' => DEFAULT_BOARD[0],
                         '@black' => DEFAULT_BOARD[1], '@captured' => [], '@available_moves' => [],
                         '@available_attacks' => [], '@current_player' => 'white', '@other_player' => 'black' }.freeze

  def initialize(chess_board_hash = DEFAULT_CHESS_HASH)
    @board_contents = chess_board_hash['@board_contents']
    @white = chess_board_hash['@white']
    @black = chess_board_hash['@black']
    @captured = chess_board_hash['@captured']
    @last_move = chess_board_hash['@last_move']
    @last_double_step = chess_board_hash['@last_double_step']
    @available_moves = chess_board_hash['@available_moves']
    @available_attacks = chess_board_hash['@available_attacks']
    @current_player = chess_board_hash['@current_player']
    @other_player = chess_board_hash['@other_player']
    default_positions
  end

  def print_board(board_display = @board_contents, system_message = '', player = @current_player)
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
                   MAGENTA
                 else
                   index.odd? ? BLUE : CYAN
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
    update_possible_moves(piece)
    possible_moves_board = map_possible_moves(piece, possible_moves_board)
    print_board(possible_moves_board, system_message)
  end

  def update_possible_moves(piece)
    @available_moves = []
    @available_attacks = []

    possible_moves = piece.is_a?(King) ? king_moves(piece) : piece.possible_moves
    possible_moves.each do |direction|
      direction&.each do |possible_move|
        break if possible_move.nil? || !can_move?(piece, possible_move)

        @available_moves << possible_move
      end
    end

    possible_attacks = piece.is_a?(Pawn) ? pawn_attacks(piece) : piece.possible_attacks

    possible_attacks.each do |direction|
      direction&.each do |possible_attack|
        break if !get_piece(possible_attack).nil? && !can_attack?(piece, possible_attack)
        
        next unless can_attack?(piece, possible_attack) && !test_possible_check(piece, possible_attack)

        @available_attacks << possible_attack
        break
      end
    end
  end

  def map_possible_moves(piece, board = self)
    @available_moves.each do |move|
      board[move[0]][move[1]] = POSSIBLE_MOVE unless test_possible_check(piece, move, @current_player)
    end

    @available_attacks.each do |attack|
      next if test_possible_check(piece, attack)

      board_square = get_piece(attack, @board_contents)
      board[attack[0]][attack[1]] = board_square.nil? ? ' P '.on_red : board_square.symbol.on_red
    end
    board
  end

  def test_possible_check(piece, move, player = @current_player)
    # Check to see if a piece making this move would put the player in check

    temp_board = copy_board
    temp_piece = temp_board.get_piece(piece.location)


    target_square = temp_board.get_piece(move)

    if !target_square.nil? || en_passant?(temp_piece, move)
      temp_board.attack(temp_piece, move)
    else
      temp_board.move(temp_piece, move)
    end

    check?(temp_board, player)
  end

  def check?(chess_board = self, player = @current_player)
    # Checks whether the player's king is currently in check

    player_pieces = player == 'white' ? chess_board.white : chess_board.black
    other_player_pieces = player == 'white' ? chess_board.black : chess_board.white
    other_player_pieces.any? do |piece|
      other_player_pieces[piece[0]]&.possible_attacks.any? do |direction|
        direction.any? do |possible_attack|
          king_in_danger = possible_attack == player_pieces[:king]&.location
          return king_in_danger if king_in_danger
          break unless get_piece(possible_attack).nil? && other_player_pieces[piece[0]].is_a?(Knight)
        end
      end
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
    Marshal.load(Marshal.dump(chess_board))
  end

  def display_selection(selection)
    selection_board = temp_board_array

    board_square = selection_board[selection[0]][selection[1]]
    selection_board[selection[0]][selection[1]] = board_square.symbol.on_green

    print_board(selection_board)
  end

  def temp_board_array
    # copies @board_contents to a temporary local board array
    board_array = []
    @board_contents.each_with_index do |column, index|
      board_array << []
      column.each { |square| board_array[index] << square.dup }
    end
    board_array
  end

  def player_piece?(piece, player)
    piece.color == player
  end

  def enemy_piece?(piece, possible_enemy)
    return false if possible_enemy == POSSIBLE_MOVE

    piece.color != possible_enemy.color unless possible_enemy.nil?
  end

  def can_move?(piece, target, player = @current_player)
    return true if castle_move?(piece, target) && !test_possible_check(piece, target, player)

    target_piece = get_piece(target)
    piece.possible_moves.any? { |direction| direction.include?(target) } && target_piece.nil?
  end

  def can_attack?(piece, target)
    possible_attacks = piece.is_a?(Pawn) ? pawn_attacks(piece) : piece.possible_attacks

    possible_attacks.any? do |direction|
      direction.any? do |possible_attack|
        possible_attack == target && (enemy_piece?(piece, get_piece(target)) || en_passant?(piece, possible_attack))
      end
    end
  end

  def en_passant?(piece, target)
    piece.is_a?(Pawn) && target == pawn_attacks(piece)[1][0]
  end

  def move(piece, target_location)
    if castle_move?(piece, target_location)
      case target_location
      when [2, 0]
        move(get_piece([0, 0]), [3, 0])
      when [6, 0]
        move(get_piece([7, 0]), [5, 0])
      when [2, 7]
        move(get_piece([0, 7]), [3, 7])
      when [6, 7]
        move(get_piece([7, 7]), [5, 7])
      end
    end

    update_piece_location(piece, target_location)
    piece.update_has_moved if piece.is_a?(King) || piece.is_a?(Rook)
  end

  def update_last_move(piece, target)
    @last_move = piece
    set_last_double_step(piece, target)
  end

  def set_last_double_step(piece, target)
    @last_double_step = piece.is_a?(Pawn) && ((piece.location[1] - target[1]).abs == 2) ? piece : nil
  end

  def attack(piece, target_location)
    target_piece = get_piece(target_location)
    other_player_pieces = @other_player == 'black' ? @black : @white
    @captured << target_piece
    if en_passant?(piece, target_location)
      @board_contents[target_location[0]][target_location[1] - 1 * piece.movement_direction] = nil
    end
    update_piece_location(piece, target_location)
    other_player_pieces.reject! { |_taken_piece_name, taken_piece| taken_piece == target_piece }
  end

  def any_possible_moves?(piece)
    update_possible_moves(piece)

    can_move = @available_moves.any? do |move|
      !test_possible_check(piece, move, @current_player)
    end

    return can_move if can_move

    @available_attacks.any? do |attack|
      !test_possible_check(piece, attack, @current_player)
    end
  end

  def update_piece_location(piece, target_location, chess_board = @board_contents)
    chess_board[piece.location[0]][piece.location[1]] = nil
    piece.location = target_location
    chess_board[target_location[0]][target_location[1]] = piece
  end

  def en_passant_attack(piece)
    left_coordinates = [piece.location[0] - 1, piece.location[1]]
    right_coordinates = [piece.location[0] + 1, piece.location[1]]
    left_side = get_piece(left_coordinates) if piece.valid_move?(left_coordinates)
    right_side = get_piece(right_coordinates) if piece.valid_move?(right_coordinates)
    return nil if (left_side.nil? && right_side.nil?) || @last_double_step.nil?

    if left_side == @last_double_step || right_side == @last_double_step
      return [@last_double_step.location[0], @last_double_step.location[1] - 1 * @last_double_step.movement_direction]
    end

    nil
  end

  def castle_move?(king, target)
    return false if !king.is_a?(King) || king.has_moved

    if king.location[1] == 0
      return true if target == [2, 0] || target == [6, 0]
    elsif king.location[1] == 7
      return true if target == [2, 7] || target == [6, 7]
    end

    false
  end

  def castle_move(king)
    return nil if king.has_moved

    castle_moves = []

    if king.color == 'white'
      if get_piece([1, 0]).nil? && get_piece([2, 0]).nil? && get_piece([3, 0]).nil?
        castle_moves << [2, 0]
      end

      if get_piece([5, 0]).nil? && get_piece([6, 0]).nil?
        castle_moves << [6, 0]
      end
    else
      if get_piece([1, 7]).nil? && get_piece([2, 7]).nil? && get_piece([3, 7]).nil?
        castle_moves << [2, 7]
      end

      if get_piece([5, 7]).nil? && get_piece([6, 7]).nil?
        castle_moves << [6, 7]
      end
    end
    castle_moves
  end

  def king_moves(piece)
    moves = piece.possible_moves
    castle_moves = castle_move(piece)
    castle_moves&.each { |move| moves[8] << move }
    moves
  end

  def pawn_attacks(piece)
    attacks = piece.possible_attacks
    attacks[1] << en_passant_attack(piece) unless en_passant_attack(piece).nil?
    attacks
  end

  def can_promote?(piece)
    piece.is_a?(Pawn) && ((@current_player == 'white' && piece.location[1] == 7) ||
    (@current_player == 'black' && piece.location[1].zero?))
  end

  def promotion_input
    print "\nEnter what you'd like to promote your pawn to: ".green
    gets.chomp
  end

  def promote(piece)
    print_board
    current_player_pieces = @current_player == 'white' ? @white : @black
    old_piece_key = current_player_pieces.find { |_key, value| value == piece }[0]
    new_piece = ''
    loop do
      promotion = promotion_input
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
                  else
                    puts "\nInvalid entry, please try again.".red
                    redo
                  end
      break unless test_possible_check(new_piece, new_piece.location)

      puts "\nInvalid entry, please try again.".red
    end
    @current_player == 'white' ? @white[old_piece_key] = new_piece : @black[old_piece_key] = new_piece
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
    @white.each_value do |piece|
      @board_contents[piece.location[0]][piece.location[1]] = piece
    end

    @black.each_value do |piece|
      @board_contents[piece.location[0]][piece.location[1]] = piece
    end
  end

  def serialize_child(obj)
    obj['@board_contents'] = @board_contents.map { |row| row.map { |piece| piece.nil? ? nil : piece.serialize } }
    obj
  end
end

# rubocop: enable Metrics/CyclomaticComplexity
# rubocop: enable Metrics/ClassLength
# rubocop: enable Metrics/MethodLength
# rubocop: enable Metrics/AbcSize
