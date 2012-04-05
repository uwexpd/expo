include ActionView::Helpers::AssetTagHelper

TINY_MCE_DEFAULT_OPTIONS = { 
  :onchange_callback => "mceTriggerSaveHandler",
  
  :theme => 'advanced',
  :theme_advanced_buttons1 => "bold,italic,|,bullist,numlist,
                              |,indent,outdent,|,undo,redo,
                              |,link,unlink,image,charmap,
                              |,visualaid,preview,cleanup,removeformat".split.join,
	:theme_advanced_buttons2 => "",
	:theme_advanced_buttons3 => "",
	:content_css => stylesheet_path("admin")
	
}

module TinyMCE
  module ClassMethods
    def uses_tiny_mce(options = {})
      tiny_mce_options = options.delete(:options) || {}
      tiny_mce_options = tiny_mce_options.merge(TINY_MCE_DEFAULT_OPTIONS)
      raw_tiny_mce_options = options.delete(:raw_options) || {}
      if !tiny_mce_options[:plugins].blank? && tiny_mce_options[:plugins].include?('spellchecker')
        tiny_mce_options.reverse_merge!(:spellchecker_rpc_url => "/" + self.controller_name + "/spellchecker")
        self.class_eval do
          include TinyMCE::SpellChecker
        end
      end
      proc = Proc.new do |c|
        c.instance_variable_set(:@tiny_mce_options, tiny_mce_options)
        c.instance_variable_set(:@raw_tiny_mce_options, raw_tiny_mce_options)
        c.instance_variable_set(:@uses_tiny_mce, true)
      end
      before_filter(proc, options)
    end
  end
end