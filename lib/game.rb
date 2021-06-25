# frozen_string_literal: true

# rubocop: disable Metrics/MethodLength

require_relative './board'
require 'pry'

# Class for chess game rules
class Game
  attr_reader :current_player

  GAME_TYPE_TEST = /^(1|2)$/.freeze
  VALID_COORDINATES = /^([A-H]|[a-h])[1-8]$/.freeze

  def initialize
    @current_player = 'white'
    @chess_board = Board.new
    @game_over = false
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
    # binding.pry
    until game_over?
      @chess_board.to_s
      chosen_piece = @chess_board.get_piece(coordinates_input)
      @chess_board.display_possible_moves(chosen_piece)
      chosen_move = move_input
      # binding.pry
      @chess_board.move(chosen_piece, chosen_move)
      @chess_board.promote(chosen_piece, promotion) if @chess_board.can_promote?(chosen_piece)
      # @chess_board.promote(chosen_piece) if @chess_board.can_promote?(chosen_piece)

      @chess_board.to_s
      switch_players
    end
    end_game
  end

  def coordinates_input
    loop do
      print "\nEnter coordinates (e.g. 'a2') for the piece you want to move: "
      coordinates = gets.chomp

      if valid_coordinates?(coordinates) && !@chess_board.get_piece(map_coordinates(coordinates)).nil? && 
         @chess_board.player_piece?(@chess_board.get_piece(map_coordinates(coordinates)), @current_player)
        return map_coordinates(coordinates)
      end

      # return map_coordinates(coordinates) if valid_coordinates?(coordinates)
      system 'clear'
      # puts 'Invalid entry, please try again.'.red
      @chess_board.to_s(@chess_board.board_contents, 'Invalid entry, please try again.'.red)
    end
  end

  def move_input
    loop do
      print "\nEnter coordinates for the square you'd like to move to: "
      coordinates = gets.chomp
      return map_coordinates(coordinates) if valid_coordinates?(coordinates)

      puts 'Invalid entry, please try again.'.red
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
    @chess_board.current_player = @current_player
  end

  def can_promote?(piece)
    # piece.is_a?(Pawn) && (@current_player == 'white' ? piece.location[1] == 7 : piece.location[1] == 0)
    piece.is_a?(Pawn) && ((@current_player == 'white' && piece.location[1] == 7) ||
    (@current_player == 'black' && piece.location[1].zero?))
  end

  def promotion
    @chess_board.to_s
    print "Enter what you'd like to promote your pawn to: "
    gets.chomp
  end

  def checkmate?

  end

  def stalemate?

  end

  def game_over?
    # checkmate?
    false
  end

  def game_won

  end

  def no_winner

  end

  def end_game
    puts stalemate? ? 'Stalemate! No winner!' : "Congrats #{@current_player} player, you win!"
  end
end

# rubocop: enable Metrics/MethodLength
