# frozen_string_literal: true

require_relative './board'
require 'pry'

# Class for chess game rules
class Game
  attr_reader :current_player

  GAME_TYPE_TEST = /^(1|2)$/

  def initialize
    @current_player = 'white'
    @chess_board = Board.new
    game_over? = false
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

  end

  def player_turn

  end

  def switch_players
    @current_player = @current_player == 'white' ? 'black' : 'white'
  end
end
