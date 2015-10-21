class Array
  def consecutive_sets number
    sets = []
    self.each_cons(number) do |set|
      sets << set if set.none?(&:nil?) and set.uniq.length == 1
    end
    return sets
  end
end
