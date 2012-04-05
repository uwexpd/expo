module OpenFlashChart

  class XAxis < Base
    def set_3d(v)
      @threed = v
    end
    # for some reason the json that needs to be produced is like this:
    # "x_axis": { "offset": false, "labels": { "labels": [ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ] } }
    # note the "labels":{"labels": ....}
    def set_labels(labels, rotate=nil, colour=nil, steps=nil)
      @labels = labels
      @labels = {:labels => labels} unless labels.is_a?(XAxisLabels)
	  if steps
	    @labels = @labels.merge({:steps=>steps})
	  end
	  if rotate
	    @labels = @labels.merge({:rotate=>rotate})
	  end
	  if colour
	    @labels = @labels.merge({:colour=>colour})
	  end
    end

    alias_method :labels=, :set_labels
  end

end