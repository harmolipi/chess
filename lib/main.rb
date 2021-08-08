# frozen_string_literal: true

require_relative './game'
require 'pry-byebug'

chess_game = Game.new

chess_game.intro_text
game_type = chess_game.game_type

case game_type
when '1'
  chess_game.two_player_game_loop
when 'load'
  chess_game.load_game
end
