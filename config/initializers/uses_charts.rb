module UsesCharts
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def uses_charts(options = {})
      proc = Proc.new do |c|
        c.instance_variable_set(:@uses_charts, true)
      end
      before_filter(proc, options)
    end
  end
end

module UsesHighCharts
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def uses_highcharts(options = {})
      proc = Proc.new do |c|
        c.instance_variable_set(:@uses_highcharts, true)
      end
      before_filter(proc, options)
    end
  end
end



ActionController::Base.send(:include, UsesCharts)
ActionController::Base.send(:include, UsesHighCharts)