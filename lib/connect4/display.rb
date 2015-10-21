module Connect4
  module Display
    def display string, options={}
      print %x{clear} if options.fetch(:clear, true)
      print String(string)
      sleep (options[:delay] || @time_between_displays)
    end
  end
end

