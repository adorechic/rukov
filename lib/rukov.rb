require "rukov/version"
require "natto"

module Rukov
  class << self
    def talk(text)
      nm = Natto::MeCab.new(rcfile: rcfile)
      nm.parse(text) do |n|
        p n
      end
    end

    def rcfile
      ENV['MECABRC'] || '/usr/local/etc/mecabrc'
    end
  end
end
