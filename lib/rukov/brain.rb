module Rukov
  class Brain
    attr_accessor :start_words, :dictionary

    def initialize
      @dictionary = {}
      @start_words = []
    end

    def save
      Pathname.new("tmp/brain").open("w") do |f|
        f.puts(Marshal.dump(self))
      end
    end
  end
end
