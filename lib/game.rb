# frozen_string_literal: true

require_relative './board'

# Class for chess game rules
class Game
  attr_reader :current_player

  GAME_TYPE_TEST = /^(1|2|load|save)$/.freeze
  VALID_COORDINATES = /^([a-h])[1-8]$/i.freeze
  YAML_FILETYPE = /^([a-z0-9\s_\\.\-():])+(.yaml)$/i.freeze
  VALID_SAVE = /^([a-z0-9\s_\\\-():])+$/i.freeze

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
    game_type = nil
    while game_type.nil?
      print "\nPress 1 to play against another human! Type 'load' to load a saved game! ".green
      game_type = game_type_input
    end
    game_type
  end

  def game_type_input
    game_type = gets.chomp.downcase
    return game_type if valid_game_type?(game_type)

    puts 'Error: invalid input. Please try again.'.red
  end

  def valid_game_type?(input)
    input.match(GAME_TYPE_TEST)
  end

  def two_player_game_loop
    until game_over?
      @chess_board.print_board(@chess_board.board_contents, @check_message)
      chosen_piece = @chess_board.get_piece(coordinates_input)
      last_square = chosen_piece.location
      @chess_board.display_possible_moves(chosen_piece)
      chosen_move = move_input(chosen_piece)
      move_or_attack(chosen_piece, chosen_move)
      @chess_board.update_last_move(chosen_piece, last_square)
      @chess_board.promote(chosen_piece) if @chess_board.can_promote?(chosen_piece)
      @chess_board.print_board
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
    @chess_board.update_possible_moves(piece)
    @chess_board.any_possible_moves?(piece) && !@chess_board.test_possible_check(piece, move, @current_player) &&
      (@chess_board.available_moves.include?(move) || @chess_board.available_attacks.include?(move))
  end

  def coordinates_input
    loop do
      print "\nEnter coordinates (e.g. 'a2') for the piece you want to move or type 'save': ".green
      coordinates = gets.chomp
      save_game if coordinates.upcase == 'SAVE'
      return map_coordinates(coordinates) if valid_selection?(coordinates)

      @chess_board.print_board(@chess_board.board_contents,
                               'Invalid entry or piece has no possible moves. Please try again.'.red)
    end
  end

  def valid_selection?(coordinates)
    return false unless valid_coordinates?(coordinates)

    chess_piece = @chess_board.get_piece(map_coordinates(coordinates))
    !chess_piece.nil? && @chess_board.player_piece?(chess_piece, @current_player) &&
      @chess_board.any_possible_moves?(chess_piece)
  end

  def move_input(piece)
    loop do
      print "\nEnter coordinates for the square you'd like to move to: ".green
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

  def switch_players
    @current_player = @current_player == 'white' ? 'black' : 'white'
    @other_player = @current_player == 'white' ? 'black' : 'white'
    @chess_board.current_player = @current_player
    @chess_board.other_player = @other_player
  end

  def copy_board
    Marshal.load(Marshal.dump(@chess_board))
  end

  def save_game
    save = @chess_board.to_yaml
    save_name = ''
    loop do
      print "\nPlease enter a name for your save: ".green
      save_name = gets.chomp
      break if save_name.match(VALID_SAVE) || save_name.match(YAML_FILETYPE)

      puts 'Invalid name! Please try again.'.red
    end

    save_name = "#{save_name}.yaml" unless save_name.match(YAML_FILETYPE)

    Dir.mkdir('./saves') unless Dir.exist?('./saves')
    File.open("./saves/#{save_name}", 'w') { |f| f.print save }
    puts "\nGame saved as '#{save_name}'!\n".green
    exit
  end

  def load_game
    saves = Dir.entries('./saves').select { |f| File.file?("./saves/#{f}") && f.match(YAML_FILETYPE) }
    if saves.empty?
      puts "Sorry, no game saves available. Starting a new game...\n".green
      Game.game_loop(secret_word, false)
      return nil
    end

    save_name = ''

    loop do
      puts "\nChoose your save file:\n".green
      saves.each { |f| puts "    - #{f}".yellow }
      print "\nWhich save would you like to load? ".green
      save_name = gets.chomp
      break if File.exist?("./saves/#{save_name}")

      system 'clear'
      puts "\nSave not found. Please try again.\n".red
    end

    save = File.open("./saves/#{save_name}").read
    # not sure why I need the below arguments for YAML#safe_load but this is the only way it works here
    loaded_save = YAML.safe_load(save, permitted_classes: [Board, Piece, Rook, Pawn, Knight, Bishop, Queen, King,
                                                           Symbol], aliases: true)
    @chess_board = loaded_save
    @current_player = @chess_board.current_player
    two_player_game_loop
  end

  def game_over?
    @checkmate || @stalemate
  end

  def end_game_conditions
    if @chess_board.check?(@chess_board, @chess_board.other_player)
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

  def end_game
    puts "\n"
    puts @stalemate ? "Stalemate! No winner!\n".green : "Checkmate! Congrats #{@other_player} player, you win!\n".green
  end
end
