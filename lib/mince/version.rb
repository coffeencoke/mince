module Mince
  module Version
    def self.major
      2
    end

    def self.minor
      3
    end

    def self.patch
      0
    end
  end

  def self.version
    [Version.major, Version.minor, Version.patch].join('.')
  end
end
