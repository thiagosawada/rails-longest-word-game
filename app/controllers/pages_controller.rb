require 'open-uri'
require 'json'

class PagesController < ApplicationController

  def game
    @grid = generate_grid(9).join(" ")
    @start_time = Time.now
  end

  def score
    grid = params[:grid].split(" ")
    @attempt = params[:word]
    start_time = Time.parse(params[:start_time])
    end_time = Time.now
    @score = run_game(@attempt, grid, start_time, end_time)
  end

  private

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    @game_letters = []
    all_letters = ("A".."Z").to_a
    grid_size.times { @game_letters << all_letters.sample }
    @game_letters
  end

  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result
    url = open("http://api.wordreference.com/0.8/80143/json/enfr/#{attempt}").read
    dictionary = JSON.parse(url)

    time = end_time - start_time
    score = attempt.size * 100 / time

    resultado = {}

    # Score deve ser zero se a palavra nao for em ingles
    if dictionary.key?("Error")
      resultado[:score] = 0
      resultado[:translation] = nil
      resultado[:message] = "not an english word"
    else
      translation = dictionary["term0"]["PrincipalTranslations"]["0"]["FirstTranslation"]["term"]
      resultado[:translation] = translation
      resultado[:time] = time

      # Validar tentativa
      answer = attempt.upcase.split("")
      if answer.all? { |l| answer.count(l) <= grid.count(l) }
        resultado[:message] = "well done"
        resultado[:score] = score
      else
        resultado[:score] = 0
        resultado[:message] = "not in the grid"
      end
    end
    resultado
  end

end
