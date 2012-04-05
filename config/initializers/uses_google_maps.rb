module UsesGoogleMaps
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def uses_google_maps(options = {})
      proc = Proc.new do |c|
        c.instance_variable_set(:@uses_google_maps, true)
      end
      before_filter(proc, options)
    end
  end
end

ActionController::Base.send(:include, UsesGoogleMaps)