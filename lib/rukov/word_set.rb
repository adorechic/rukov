require "natto"

module Rukov
  class WordSet
    END_CHARS = %w(。)

    def self.end_char?(char)
      END_CHARS.include?(char)
    end

    def initialize(text)
      nm = Natto::MeCab.new(rcfile: rcfile)
      @nodes = []
      nm.parse(text) do |n|
        @nodes << n
      end
    end

    def each_set
      started = true
      @nodes.each.with_index do |prefix1, index|
        if self.class.end_char?(prefix1.surface)
          started = true
          next
        end
        prefix2, suffix = @nodes[index + 1], @nodes[index + 2]

        if prefix2 && suffix
          next if self.class.end_char?(prefix2.surface)

          yield prefix1, prefix2, suffix, started

          started = false
        end
      end
    end

    private
    def rcfile
      ENV['MECABRC'] || '/usr/local/etc/mecabrc'
    end
  end
end
