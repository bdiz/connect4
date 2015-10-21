
module Connect4
  class Column < Array

    class OverflowError < RuntimeError
    end

    def insert disk
      index = self.find_index(nil)
      raise OverflowError if index.nil?
      self[index] = disk
    end

  end
end
