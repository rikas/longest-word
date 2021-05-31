class GamesController < ApplicationController
  VOWELS = %w[A E I O U Y]

  # get '/new', to: 'games#new'
  def new
    # An array with 5 random vowels
    @letters = Array.new(5) { VOWELS.sample }

    # Add an array with 5 random consonants
    @letters += Array.new(5) { (('A'..'Z').to_a - VOWELS).sample }

    # Shuffle the letters!
    @letters = @letters.shuffle
  end

  # post '/score', to: 'games#score'
  def score
    word = params[:word]
    letters = params[:letters].split
    time_taken = Time.now - Time.parse(params[:time])

    # Get an array with score and message, depending on the word provided, the available letters and
    # the time taken.
    message = compute_message(word, letters)

    # Get the score, based on the word size and time taken to type the word
    score = compute_score(word, time_taken).round(2)

    # This @result ivar is what the view will use. To make it easier (not setting a lot of ivars) we
    # use just a single variable (array) with multiple fields.
    @result = {
      score: score,
      message: message,
      time_taken: time_taken,
      invalid: message.start_with?('Sorry')
    }
  end

  private

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(word, time_taken)
    time_taken > 60.0 ? 0 : word.size * (1.0 - time_taken / 60.0)
  end

  def compute_message(word, grid)
    if included?(word.upcase, grid)
      if english_word?(word)
        "Congratulations! #{word} is a valid English word!"
      else
        "Sorry but #{word} does not seem to be a valid English word..."
      end
    else
      "Sorry but #{word} can't be built out of #{grid}"
    end
  end

  def english_word?(word)
    response = RestClient.get("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.body, symbolize_names: true)

    # Will be true or false — check the response from wagon-dictionary.herokuapp.com and you will
    # understand where this is coming from :)
    json[:found]
  end
end
