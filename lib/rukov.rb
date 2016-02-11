require "rukov/version"
require 'pathname'
require 'rukov/word_set'
require 'rukov/brain'
require 'open-uri'

module Rukov
  class << self
    def study(path)
      if path.start_with?('http')
        body = open(path).read.
               gsub(%r{<head.+?</head>}m, '').
               gsub(%r{<!--.+?-->}m, '').
               gsub(%r{<script[^<]+</script>}, '').
               gsub(/<[^>]+>/, '').
               gsub(/\r?\n/, '')
        learn(body)
      else
        learn(Pathname.new(path).read)
      end
    end

    def learn(text)
      brain = Brain.new

      WordSet.new(text).each_set do |prefix1, prefix2, suffix, start_word|
        brain.memory(prefix1.surface, prefix2.surface, suffix.surface)
        if start_word
          brain.start_words << prefix1.surface
          brain.start_words.uniq!
        end
      end

      brain.save
    end

    def clear
      Brain.load.clear
    end

    def speak
      brain = Brain.load

      message = ""

      prefix1 = brain.start_words.sample
      message << prefix1
      prefix2 = brain.dictionary[prefix1].keys.sample

      if prefix2
        message << prefix2

        loop do
          dict1 = brain.dictionary[prefix1]
          break unless dict1

          suffix = Array(dict1[prefix2]).sample

          break unless suffix
          message << suffix

          prefix1 = prefix2
          prefix2 = suffix
        end
      end

      message
    end

  end
end
