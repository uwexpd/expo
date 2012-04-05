module OpenFlashChart

  class LineDot < LineBase
    def initialize args={}
      super
      @type = "line"
    end
  end

  class DotValue < Base
    def initialize(value, args={})
      @value = value
      super(args)
    end
	def set_colour(colour)
		self.colour = colour
	end
  end
  
  class DotStyle < Base
    def initialize(colour, size, args={})
      self.type = "solid-dot"
      self.colour = colour
      self.size = size
      super(args)
    end
  end
  
end
