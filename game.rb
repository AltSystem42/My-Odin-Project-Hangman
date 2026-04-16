require 'json'

f = File.open('./dic.txt')
dict = []
count = -1
while word = f.gets do
  dict << word.chomp
  count += 1
end
f.close

class Display
  attr_accessor :guessed, :answer, :screen

  def initialize(word_length, answer)
    @screen = '_' * word_length
    @answer = answer
    @guessed = ""
  end
  def display_board
    puts @screen
    puts
    puts "guess a letter"
    puts
  end
  def solve(line)
    line.each_with_index { |state, index|
      if state == true
        @screen[index] = @answer[index]
      end
    }
    display_board
  end
end

class LoadProgress
  def load
    data = {}
    File.open("./save.json", "r") do |file|
      data = JSON.parse(file.read)
    end
    return data
  end
end

class Progress
  attr_accessor :io, :round, :display
  def initialize(io, round, display)
    @display = display
    @round = round
    @io = io
  end
  def save
    data = {
      io: @io,
      round: @round,
      display: {
        answer: @display.answer,
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
  def initialize(dict, count)
    @answer = word(dict[rand(count)], dict, count)
    @display = Display.new(@answer.length, @answer)
    @word_length = @answer.length
    @progress = Progress.new("OFF", @round, @display)
    @round = (@progress.io == "ON" ? @progress.round : 0)
    @load = LoadProgress.new
    @display.display_board
  end

  def guess(input)
    checklist = []
    @answer.each_char {|char|  
    if char == input
      checklist << true
    else
      checklist << false
    end}
    return checklist
  end

    def word(w, dict, count)
      if w.length.between?(5,12)
        w
      else
        word(dict[rand(count)], dict, count)
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
    int = 0
      @answer.chars.each_with_index {|element, index| 
        if element == @display.screen[index]
          int += 1
        end}
    if int == @word_length
      return true
    else
      return false
    end
  end

  def load
    data = @load.load
        if data["io"] == "ON"
          @progress.io = "OFF"
          system("clear")
          @round = data["round"]
          @display = Display.new(data["display"]["answer"].length, data["display"]["answer"])
          @display.guessed = data["display"]["guessed"]
          @display.screen = data["display"]["screen"]
          @display.answer = data["display"]["answer"]
          @answer = data["display"]["answer"]
          @progress.save
          puts "letters you have guessed:#{@display.guessed}"
          puts "You have #{6 - @round} remaining guessess"
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
        if line.all?(false)
          @round += 1
          puts "You have #{6 - @round} remaining guesses"
        end
        @display.solve(line)
      elsif input == "exit"
        break
      elsif input == "save"
        @progress.io = "ON"
        @progress.round = @round
        @progress.display = @display
        @progress.save
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
  def initialize(dict, count)
    @dict = dict
    @count = count
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
      game = Game.new(@dict, @count)
      game.run
    elsif load?(input)
      game = Game.new(@dict, @count)
      if game.load
        game.run
      end
    end
  end
end

main = Main.new(dict, count)
main.run


