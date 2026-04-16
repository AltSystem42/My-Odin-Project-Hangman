require 'json'

f = File.open('./dic.txt')
dict = []
while word = f.gets do
  dict << word.chomp
end
f.close

class Display
  attr_accessor :guessed, :screen

  def initialize(word_length)
    @screen = '_' * word_length
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
    return data
  end
end

class Progress
  attr_accessor :round, :display
  def initialize( round, display)
    @display = display
    @round = round
  end
  def save(answer)
    data = {
      round: @round,
      display: {
        answer: answer,
        guessed: @display.guessed,
        screen: @display.screen
      }
    }
    File.open("./save.json", "w") do |file|
      file.puts JSON.generate(data)
    end
  end
end

class Game
  def initialize(dict, desc)
    @answer = word(dict[rand(dict.length)], dict)
    @display = Display.new(@answer.length)
    @round = 0
    @progress = Progress.new(@round, @display)
    @load = LoadProgress.new
    desc == "load" ?  false : @display.display_board
  end

  def guess(input)
    found = false
    @answer.chars.each_with_index {|element, index| 
    if element == input
      @display.screen[index] = input
      found = true
    end}
    return found
  end

    def word(w, dict)
      if w.length.between?(5,12)
        w
      else
        word(dict[rand(dict.length)], dict)
      end
    end

  def letter?(char)
    if char.length == 1
      char.match?(/[A-Za-z]/)
    else
      return false
    end
  end

  def finished?
   @display.screen == @answer
  end

  def load
    data = @load.load
        if !data.empty?
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
          return true
        else
          return false
        end
  end

  def run
    while @round < 6
        input = gets.chomp.downcase
      if letter?(input) 
        system("clear")
        @display.guessed << "#{input},"
        puts "letters you have guessed:#{@display.guessed}"
        line = guess(input)
        unless line
          @round += 1
          puts "You have #{6 - @round} remaining guesses"
          @display.display_board
        else
          puts "You have #{6 - @round} remaining guesses"
          @display.display_board
        end
      elsif input == "exit"
        break
      elsif input == "save"
        @progress.round = @round
        @progress.display = @display
        @progress.save(@answer)
      elsif input == "load"
        load
      else
        puts "invalid input"
      end
      if finished?
        puts "YOU WIN!"
        break
      end
    end
    if @round == 6
      puts "YOU LOSE"
      puts "The word was: #{@answer}"
    end
  end
end

class Main
  def initialize(dict)
    @dict = dict
  end
  def new?(game)
    game == "new" ? true : false
  end
  def load?(game)
    game == "load" ? true : false
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
      if game.load
        game.run
      else
        puts "no saved game"
      end 
    end
  end
end

main = Main.new(dict)
main.run


