# frozen_string_literal: true

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
    puts "\n"
    @chess_board.to_s
    puts "\n"
    # print "Enter the coordinates (e.g. 'a1') for the piece you'd like to move: "
    chosen_piece = coordinates_input
    p chosen_piece
  end

  def coordinates_input
    loop do
      print "Enter coordinates (e.g. 'a2') for the piece you want to move: "
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
  end
end
