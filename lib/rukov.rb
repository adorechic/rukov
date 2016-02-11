require "rukov/version"
require "natto"
require 'pathname'
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

          brain.memory(prefix1.surface, prefix2.surface, suffix.surface)

          if started
            started = false
            brain.start_words << prefix1.surface
            brain.start_words.uniq!
          end
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

    def rcfile
      ENV['MECABRC'] || '/usr/local/etc/mecabrc'
    end
  end
end
