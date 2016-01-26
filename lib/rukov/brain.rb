module Rukov
  class Brain
    attr_accessor :start_words, :dictionary

    def initialize
      @dictionary = {}
      @start_words = []
    end
  end
end
