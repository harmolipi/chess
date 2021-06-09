# frozen_string_literal: true

class Game
  def initialize
    @current_player = 'white'
  end

  def switch_players
    @current_player = @current_player == 'white' ? 'black' : 'white'
  end
end
