require "rukov/version"
require "natto"
require 'pathname'

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

      hash = {}
      started = true
      start_words = []
      nodes.each.with_index do |prefix1, index|
        if prefix1.surface == "。"
          started = true
          next
        end
        prefix2, suffix = nodes[index + 1], nodes[index + 2]

        if prefix2 && suffix
          next if prefix2.surface == "。"

          hash[prefix1.surface] ||= {}
          hash[prefix1.surface][prefix2.surface] ||= []

          if suffix.surface == "。"
            hash[prefix1.surface][prefix2.surface] << ""
          else
            hash[prefix1.surface][prefix2.surface] << suffix.surface
          end

          if started
            started = false
            start_words << prefix1.surface
            start_words.uniq!
          end

          hash[prefix1.surface][prefix2.surface].uniq!
        end
      end

      p start_words

      hash
    end

    def rcfile
      ENV['MECABRC'] || '/usr/local/etc/mecabrc'
    end
  end
end
