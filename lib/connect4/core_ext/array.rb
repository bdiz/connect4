class Array
  # TODO add more arguments to make generic
  def consecutive_sets number
    sets = []
    self.each_cons(number) do |set|
      sets << set if set.none?(&:empty?) and set.uniq.length == 1
    end
    return sets
  end
end
