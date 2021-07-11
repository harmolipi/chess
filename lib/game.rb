# frozen_string_literal: true

# rubocop: disable Metrics/MethodLength
# rubocop: disable Metrics/ClassLength
# rubocop: disable Metrics/AbcSize
# rubocop: disable Metrics/CyclomaticComplexity

require_relative './board'
require 'pry'
require 'msgpack'

# Class for chess game rules
class Game
  attr_reader :current_player

  GAME_TYPE_TEST = /^(1|2)$/.freeze
  VALID_COORDINATES = /^([A-H]|[a-h])[1-8]$/.freeze

  def initialize
    @current_player = 'white'
    @chess_board = Board.new
    @game_over = false
    @checkmate = false
    @check_message = ''
    @move_counter = 0
  end

  def intro_text
    system 'clear'
    puts "\nWelcome to Chess!"
  end

  def game_type
    # binding.pry
    game_type = nil
    while game_type.nil?
      print "\nPress 1 to play against another human! "
      game_type = game_type_input
    end
    game_type
  end

  def game_type_input
    game_type = gets.chomp
    return game_type if valid_game_type?(game_type)

    puts 'Error: invalid input. Please try again.'.red
  end

  def valid_game_type?(input)
    input.match(GAME_TYPE_TEST)
  end

  def two_player_game_loop
    until game_over?
      @chess_board.to_s(@chess_board.board_contents, @check_message) # eventually change .to_s to .print_board
      chosen_piece = @chess_board.get_piece(coordinates_input)
      last_square = chosen_piece.location
      @chess_board.display_possible_moves(chosen_piece)
      chosen_move = move_input(chosen_piece)
      move_or_attack(chosen_piece, chosen_move)
      @chess_board.update_last_move(chosen_piece, last_square)
      # binding.pry
      @chess_board.promote(chosen_piece, promotion) if @chess_board.can_promote?(chosen_piece)
      @chess_board.to_s
      end_game_conditions
      switch_players
    end
    end_game
  end

  def move_or_attack(piece, target)
    if @chess_board.can_move?(piece, target)
      @chess_board.move(piece, target)
      @move_counter += 1
    elsif @chess_board.can_attack?(piece, target)
      @chess_board.attack(piece, target)
      @move_counter = 0
    end
  end

  def check_move(piece, move)
    @chess_board.any_possible_moves?(piece) && !@chess_board.test_possible_check(piece, move, @current_player) &&
      (piece.possible_moves.any? { |direction| direction.include?(move) } ||
      piece.possible_attacks.any? { |direction| direction.include?(move) })
  end

  def coordinates_input
    loop do
      print "\nEnter coordinates (e.g. 'a2') for the piece you want to move: "
      coordinates = gets.chomp
      return map_coordinates(coordinates) if valid_selection?(coordinates)

      @chess_board.to_s(@chess_board.board_contents, 'Invalid entry, please try again.'.red)
    end
  end

  def valid_selection?(coordinates)
    return false unless valid_coordinates?(coordinates)

    # binding.pry
    chess_piece = @chess_board.get_piece(map_coordinates(coordinates))
    !chess_piece.nil? && @chess_board.player_piece?(chess_piece, @current_player) &&
      @chess_board.any_possible_moves?(chess_piece)
  end

  def move_input(piece)
    loop do
      print "\nEnter coordinates for the square you'd like to move to: "
      coordinates = gets.chomp

      if valid_coordinates?(coordinates) && check_move(piece, map_coordinates(coordinates))
        return map_coordinates(coordinates)
      end

      @chess_board.display_possible_moves(piece, 'Invalid entry, please try again.'.red)
    end
  end

  def map_coordinates(coordinates)
    # converts chess coordinates to array coordinates
    [coordinates[0].downcase.codepoints[0] - 97, coordinates[1].to_i - 1]
  end

  def valid_coordinates?(coordinates)
    coordinates.match(VALID_COORDINATES)
  end

  def player_turn

  end

  def switch_players
    @current_player = @current_player == 'white' ? 'black' : 'white'
    @other_player = @current_player == 'white' ? 'black' : 'white'
    @chess_board.current_player = @current_player
    @chess_board.other_player = @other_player
  end

  def can_promote?(piece)
    piece.is_a?(Pawn) && ((@current_player == 'white' && piece.location[1] == 7) ||
    (@current_player == 'black' && piece.location[1].zero?))
  end

  def promotion
    @chess_board.to_s
    print "\nEnter what you'd like to promote your pawn to: "
    gets.chomp
  end

  def check?(chess_board = @chess_board, player = @current_player)
    current_player_pieces = player == 'white' ? chess_board.white : chess_board.black
    other_player_pieces = player == 'white' ? chess_board.black : chess_board.white
    other_king = other_player_pieces[:king]
    current_player_pieces.any? do |piece|
      current_player_pieces[piece[0]].possible_moves.any? { |direction| direction.include?(other_king.location) } ||
        current_player_pieces[piece[0]].possible_attacks.any? { |direction| direction.include?(other_king.location) }
    end
  end

  def copy_board
    Marshal.load(Marshal.dump(@chess_board))
  end

  def checkmate?
    # binding.pry
    current_player_pieces = @current_player == 'white' ? @chess_board.white : @chess_board.black
    other_player_pieces = @current_player == 'white' ? @chess_board.black : @chess_board.white
    other_king = other_player_pieces[:king]
    is_checkmate = true
    other_player_pieces.each do |piece|
      # binding.pry
      other_player_piece = other_player_pieces[piece[0]]
      other_player_piece.possible_moves.each do |direction|
        # binding.pry
        next if direction.empty?
        direction.each do |move|
          next if move.nil?
  
          unless test_possible_check(other_player_piece, move)
            is_checkmate = false
            break
          end
        end
        break unless is_checkmate
      end
      
      return is_checkmate unless is_checkmate

      other_player_piece.possible_attacks.each do |direction|
        direction.each do |attack|
          next if attack.nil?

          unless test_possible_check(other_player_piece, attack)
            is_checkmate = false
            break
          end
        end
        break unless is_checkmate
      end
      is_checkmate
    end
  end

  def test_possible_check(piece, move, player = @current_player)
    temp_board = copy_board
    temp_other_player_piece = temp_board.get_piece(piece.location)
    temp_board.move(temp_other_player_piece, move)
    check?(temp_board, player)
  end

  def game_over?
    @checkmate || @stalemate
  end

  def end_game_conditions
    if @chess_board.check?
      @check_message = 'Check!'.blue
      if @chess_board.checkmate?
        @checkmate = true
        @check_message = 'Checkmate!'.blue
      end
    elsif @chess_board.stalemate?
      @stalemate = true
    else
      @check_message = ''
    end
  end

  def game_won

  end

  def no_winner

  end

  def end_game
    puts "\n"
    puts @stalemate ? 'Stalemate! No winner!'.green : "Checkmate! Congrats #{@other_player} player, you win!".green
  end
end

# rubocop: enable Metrics/CyclomaticComplexity
# rubocop: enable Metrics/AbcSize
# rubocop: enable Metrics/ClassLength
# rubocop: enable Metrics/MethodLength
