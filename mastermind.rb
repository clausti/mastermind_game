module Mastermind
  
  class Game

    def initialize(num_turns)
      @player = Player.new
      @num_turns = num_turns
    end

    def ask_guess
      puts "What's your guess?"
      valid_guess = false
      until valid_guess
        guess = @player.tell_guess
        valid_guess = @board.valid_guess?(guess)
        puts "Invalid guess. Try again?" unless valid_guess
      end
      @board.store_guess(guess)
    end

    def play
      @board = Board.new(@num_turns)
      turns_left = @num_turns
      @board.set_code
      @board.render
      while turns_left > 0
        ask_guess
        @board.give_feedback
        @board.render

        if @board.winning?
          puts "You win!"
          return
        end
        turns_left -= 1
      end
      puts "Game Over (you lose.)"
    end

  end


  class Board

    PEG_COLORS = ["R", "G", "B", "Y", "O", "P"]

    def initialize(num_turns)
      @prev_guesses = []
      @feedback = []
      @board_size = num_turns
    end

    def set_code
      @code = []
      4.times do
        @code << PEG_COLORS.sample
      end
    end

    def render
      prev_guess_strings = @prev_guesses.map {|guess| guess.join(" ") }
      feedback_strings = @feedback.map {|feedback| feedback.join(" ") }

      prev_guess_strings.zip(feedback_strings) do |guess, feedback|
        puts "#{guess} | #{feedback}"
      end

      blank_rows = @board_size - @prev_guesses.length
      blank_rows.times do
        puts "_ _ _ _ | _ _ _ _"
      end
    end

    def valid_guess?(guess)
      return false if guess.length != 4
      valid = true
      guess.each do |peg|
        unless PEG_COLORS.include?(peg)
          puts "Can't choose color #{peg}"
          valid = false
        end
      end
      valid
    end

    def store_guess(guess)
      @prev_guesses << guess
    end

    def give_feedback
      current_guess = @prev_guesses[-1]
      feedback = []

      in_place = 0 # count of "B"
      current_guess.each_with_index do |peg, index|
        in_place += 1 if @code[index] == peg
      end

      present = sum_b_w # count of both "B" and "W"

      in_place.times do
        feedback << "B"
      end
      (present-in_place).times do
        feedback << "W"
      end
      (4-present).times do
        feedback << "_"
      end
      @feedback << feedback
    end

    def sum_b_w
      guess_colors = color_hash(@prev_guesses[-1])
      code_colors = color_hash(@code)
      color_min_hash = guess_colors.merge(code_colors) do |key, guess_col, code_col|
        [guess_col, code_col].min
      end
      sum_present = 0
      color_min_hash.each do |color, count|
        sum_present += count
      end
      sum_present
    end

    def color_hash(peg_arr)
      peg_hash = {}
      PEG_COLORS.each do |color|
        peg_hash[color] = 0
      end
      peg_arr.each do |color|
        peg_hash[color] += 1
      end
      peg_hash
    end

    def winning?
      @feedback[-1] == ["B", "B", "B", "B"]
    end

  end

  class Player

    def tell_guess
      gets.upcase.chomp.split('')
    end

  end

end

if __FILE__ == $PROGRAM_NAME
  ourgame = Mastermind::Game.new(10)
  ourgame.play
end

