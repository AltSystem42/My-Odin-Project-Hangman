require "json"

dict = File.readlines("./dic.txt", chomp: true)

class Display
  attr_accessor :guessed, :screen

  def initialize(word_length)
    @screen = "_" * word_length
    @guessed = ""
  end

  def display_board
    puts @screen
    puts
    puts "guess a letter OR save/exit/load"
    puts
  end

  def restore(screen, guessed)
    @screen = screen
    @guessed = guessed
  end
end

class LoadProgress
  def load
    data = {}
    if File.exist?("./save.json")
      File.open("./save.json", "r") do |file|
        data = JSON.parse(file.read)
      end
    end
    data
  end
end

class Progress
  attr_accessor :round, :display

  def initialize(round, display)
    @display = display
    @round = round
  end

  def save(answer)
    {
      round: @round,
      display: {
        answer: answer,
        guessed: @display.guessed,
        screen: @display.screen
      }
    }
    JSON.parse(File.read("./save.json"))
  end
end

class Game
  def initialize(dict, desc)
    @answer = pick_word(dict[rand(dict.length)], dict)
    @display = Display.new(@answer.length)
    @round = 0
    @progress = Progress.new(@round, @display)
    @load = LoadProgress.new
    @display.display_board unless desc == "load"
  end

  def guess(input)
    found = false
    @answer.chars.each_with_index do |element, index|
      if element == input
        @display.screen[index] = input
        found = true
      end
    end
    found
  end

  def pick_word(word, dict)
    if word.length.between?(5, 12)
      word
    else
      pick_word(dict[rand(dict.length)], dict)
    end
  end

  def letter?(char)
    return false unless char.length == 1

    char.match?(/[A-Za-z]/)
  end

  def finished?
    @display.screen == @answer
  end

  def load_data
    data = @load.load
    return false if data.empty?

    system("clear")
    @round = data["round"]
    guessed = data["display"]["guessed"]
    screen = data["display"]["screen"]
    answer = data["display"]["answer"]
    @display.restore(screen, guessed)
    @answer = answer
    puts "letters you have guessed:#{@display.guessed}"
    puts "You have #{6 - @round} remaining guesses"
    @display.display_board
    true
  end

  def run
    while @round < 6
      input = gets.chomp.downcase
      if letter?(input)
        system("clear")
        @display.guessed << "#{input},"
        puts "letters you have guessed:#{@display.guessed}"
        line = guess(input)
        @round += 1 unless line
        puts "You have #{6 - @round} remaining guesses"
        @display.display_board
      elsif input == "exit"
        break
      elsif input == "save"
        @progress.round = @round
        @progress.display = @display
        @progress.save(@answer)
      elsif input == "load"
        load_data
      else
        puts "invalid input"
      end
      if finished?
        puts "YOU WIN!"
        break
      end
    end
    return unless @round == 6

    puts "YOU LOSE"
    puts "The word was: #{@answer}"
  end
end

class Main
  def initialize(dict)
    @dict = dict
  end

  def new?(game)
    game == "new"
  end

  def load?(game)
    game == "load"
  end

  def run
    system("clear")
    puts "(New/Load) game."
    input = gets.chomp.downcase
    if new?(input)
      game = Game.new(@dict, input)
      game.run
    elsif load?(input)
      game = Game.new(@dict, input)
      if game.load_data
        game.run
      else
        puts "no saved game"
      end
    end
  end
end

main = Main.new(dict)
main.run
