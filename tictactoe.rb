# frozen_string_literal: false
# Holds information about the overall gamestate
class GameBoard
  attr_reader :board, :players
  attr_accessor :end_game, :current_player, :other_player

  SIZE = 3
  H_LINE = "#{'---' * SIZE}\n".freeze

  def initialize(players)
    @board = default_board
    @end_game = false
    @players = players
    @current_player, @other_player = players.shuffle
  end

  def to_s
    board_img = ''
    SIZE.times do |i|
      SIZE.times do |j|
        mark = board[i][j].mark
        mark == '' ? board_img.concat(' ') : board_img.concat(mark)
        j == SIZE - 1 ? board_img.concat("\n") : board_img.concat(' | ')
      end
      board_img.concat(H_LINE) if i != SIZE - 1
    end
    board_img
  end

  def switch_player
    self.current_player, self.other_player = other_player, current_player
  end

  def ask_for_move(player)
    valid = false
    until valid
      puts "#{player.name}'s turn. Where would you like to mark? Indicate using 'row,col' with top corner being 0,0"
      location = gets.chomp
      valid = process_move(player, location)
      puts 'Invalid move.' unless valid
    end
  end

  private

  def process_move(player, player_choice)
    coords = player_choice.split(',').map(&:to_i)
    cell = board[coords[0]][coords[1]]
    if valid_move?(cell)
      update_board(player, cell)
      if game_over?(coords[0], coords[1])
        self.end_game = true
      end
    else
      return false
    end
    true
  end

  def game_over?(row, col)
    win?(row, col) || tie?
  end

  def win?(row, col)
    row_win?(row) || col_win?(col) || diag_win?
  end

  def tie?
    board.all? do |row|
      row.all? { |cell| cell.mark != '' }
    end
  end

  def col_win?(num)
    prev = board[0][num].mark
    (1...SIZE).each do |i|
      cur = board[i][num].mark
      return false if (cur != prev) || (cur == '')

      prev = cur
    end
    true
  end

  def row_win?(num)
    prev = board[num][0].mark
    (1...SIZE).each do |i|
      cur = board[num][i].mark
      return false if (cur != prev) || (cur == '')

      prev = cur
    end
    true
  end

  def diag_win?
    main_diagonal_win? || anti_diagonal_win?
  end

  def main_diagonal_win?
    i = 0
    prev = board[0][0].mark
    (1...SIZE).each do |j|
      i += 1
      cur = board[i][j].mark
      return false if (cur != prev) || (cur == '')

      prev = cur
    end
    true
  end

  def anti_diagonal_win?
    i = SIZE - 1
    prev = board[i][0].mark
    (1...SIZE).each do |j|
      i -= 1
      cur = board[i][j].mark
      return false if (cur != prev) || (cur == '')

      prev = cur
    end
    true
  end

  def valid_move?(cell)
    cell.mark == ''
  end

  def update_board(player, cell)
    cell.mark = player.marker
  end

  def default_board
    board = []
    SIZE.times do
      row = []
      SIZE.times { row << Cell.new }
      board << row
    end
    board
  end
end

# Holds information about the particular Cell
class Cell
  attr_accessor :mark

  def initialize(mark = '')
    @mark = mark
  end
end

# Tracks information about an individual Player
class Player
  attr_reader :name, :marker

  def initialize(name, marker)
    @name = name
    @marker = marker
  end

  def to_s
    "#{name} uses '#{marker}' as a marker."
  end
end

def play_game
  player_one, player_two = [setup_player('one'),setup_player('two')]
  puts player_one
  puts player_two
  game = GameBoard.new([player_one, player_two])
  until game.end_game
    game.switch_player
    puts game
    game.ask_for_move(game.current_player)
  end
  puts "#{game.current_player.name} is the winner!"
end

def setup_player(player_num)
  puts "What is the name of player #{player_num}"
  player_name = gets.chomp

  puts 'What symbol would you like to use?'
  player_sym = gets.chomp

  Player.new(player_name, player_sym)
end
