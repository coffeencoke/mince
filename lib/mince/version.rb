module Mince
  module Version
    def self.major
      2
    end

    def self.minor
      0
    end

    def self.patch
      '0.pre.3'
    end
  end

  def self.version
    [Version.major, Version.minor, Version.patch].join('.')
  end
end
