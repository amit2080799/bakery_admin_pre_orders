class FileReader
  attr_reader :path
  attr_accessor :file

  def initialize(path)
    @path = path
    @file = nil
  end

  def open
    self.file = File.open(path)
  end

  def close
    file.close
  end
end
