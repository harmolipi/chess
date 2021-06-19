# frozen_string_literal: true

require_relative './game'
require 'pry'

chess_game = Game.new

chess_game.intro_text
if chess_game.game_type == '1'
  chess_game.two_player_game_loop
  # puts '2-player'
else
  # chess_game.one_player_game_loop
  puts '1-player'
end
# system 'clear'
