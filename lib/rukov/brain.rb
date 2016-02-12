module Rukov
  class Brain
    attr_accessor :start_words, :dictionary

    def initialize
      @dictionary = {}
      @start_words = []
    end

    def memory(prefix1, prefix2, suffix)
      suffixes(prefix1, prefix2) << WordSet.end_char?(suffix) ? "" : suffix
      suffixes(prefix1, prefix2).uniq!
    end

    def save
      Pathname.new("tmp/brain").open("w") do |f|
        f.puts(Marshal.dump(self))
      end
    end

    def clear
      initialize
      save
    end

    def self.load
      Marshal.load(Pathname.new("tmp/brain").read)
    end

    private

    def suffixes(prefix1, prefix2)
      dictionary[prefix1] ||= {}
      dictionary[prefix1][prefix2] ||= []
    end
  end
end
