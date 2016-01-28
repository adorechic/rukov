require "rukov/version"
require "natto"
require 'pathname'
require 'rukov/brain'

module Rukov
  class << self
    def study(path)
      learn(Pathname.new(path).read)
    end

    def learn(text)
      nm = Natto::MeCab.new(rcfile: rcfile)
      nodes = []
      nm.parse(text) do |n|
        nodes << n
      end

      brain = Brain.new

      started = true
      nodes.each.with_index do |prefix1, index|
        if prefix1.surface == "。"
          started = true
          next
        end
        prefix2, suffix = nodes[index + 1], nodes[index + 2]

        if prefix2 && suffix
          next if prefix2.surface == "。"

          brain.dictionary[prefix1.surface] ||= {}
          brain.dictionary[prefix1.surface][prefix2.surface] ||= []

          if suffix.surface == "。"
            brain.dictionary[prefix1.surface][prefix2.surface] << ""
          else
            brain.dictionary[prefix1.surface][prefix2.surface] << suffix.surface
          end

          if started
            started = false
            brain.start_words << prefix1.surface
            brain.start_words.uniq!
          end

          brain.dictionary[prefix1.surface][prefix2.surface].uniq!
        end
      end

      p brain.start_words
      brain.save

      brain.dictionary
    end

    def rcfile
      ENV['MECABRC'] || '/usr/local/etc/mecabrc'
    end
  end
end
