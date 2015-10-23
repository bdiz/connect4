
module Connect4
  class Column < Array

    class OverflowError < RuntimeError
    end
    class UnderflowError < RuntimeError
    end

    def insert disk
      index = self.find_index(Space.get)
      raise OverflowError if index.nil?
      self[index] = disk
    end

    def remove
      index = self.find_index(Space.get)
      if index.nil? # full
        self[length-1].tap { self[length-1] = Space.get }
      elsif index == 0 # empty
        raise UnderflowError
      else
        self[index-1].tap { self[index-1] = Space.get }
      end
    end

  end
end
