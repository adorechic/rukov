require "rukov/version"
require "natto"

module Rukov
  class << self
    def talk(text)
      nm = Natto::MeCab.new(rcfile: rcfile)
      nodes = []
      nm.parse(text) do |n|
        nodes << n
      end

      hash = {}
      nodes.each.with_index do |prefix1, index|
        prefix2, suffix = nodes[index + 1], nodes[index + 2]

        if prefix2 && suffix
          hash[prefix1.surface] ||= {}
          hash[prefix1.surface][prefix2.surface] ||= []
          hash[prefix1.surface][prefix2.surface] << suffix.surface
          hash[prefix1.surface][prefix2.surface].uniq!
        end
      end

      hash
    end

    def rcfile
      ENV['MECABRC'] || '/usr/local/etc/mecabrc'
    end
  end
end
