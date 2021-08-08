# frozen_string_literal: true

require_relative './game'
require 'pry-byebug'

chess_game = Game.new

chess_game.intro_text
game_type = chess_game.game_type
if game_type == '1'
  chess_game.two_player_game_loop
  # puts '2-player'
elsif game_type == 'load'
  chess_game.load_game
else
  # chess_game.one_player_game_loop
  puts '1-player'
end
# system 'clear'
