require 'pdf/writer'
require 'htmldoc'

module ActionView # :nodoc:
  
  # Uses PDF::Writer to write a pdf from scratch.
  # details at http://info.michael-simons.eu/2008/11/24/pdfwriter-and-ruby-on-rails-222/
  class PDFRender
    PAPER = 'LETTER'
    include ApplicationHelper
    include ActionView::Helpers::TranslationHelper
    include ActionView::Helpers::AssetTagHelper
    include ActionView::Helpers::TextHelper      
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::SanitizeHelper
  
    def self.call(template)
      "ActionView::PDFRender.new(self).render(template, local_assigns)"
    end
   
    def initialize(action_view)
      @action_view = action_view
    end
   
    # Render the PDF
    def render(template, local_assigns = {})
      @action_view.controller.headers["Content-Type"] ||= 'application/pdf'
         
      # Retrieve controller variables
      @action_view.controller.instance_variables.each do |v|
        instance_variable_set(v, @action_view.controller.instance_variable_get(v))
      end
         
      pdf = ::PDF::Writer.new( :paper => @paper || PAPER )
      pdf.compressed = true if RAILS_ENV != 'development'
      eval template.source, nil, ''
      
      pdf.render
    end
   
    # def self.compilable?
    #   false
    # end
    #    
    # def compilable?
    #   self.class.compilable?
    # end
  end

end

module ActionController
  class Base
    
    # Generates a pdf using HTMLDoc and then sends it to the browser using the specified filename. Filename can either include the
    # ".pdf" extension or not; it will be added to the end of the filename if not present. This is a convenience wrapper 
    # for calling send_data(render_to_pdf(options...)) or something similar. Defaults to sending the PDF inline (but can be overridden).
    # Accepts the same options as send_data.
    def send_pdf(filename = "Output.pdf", options = {}, pdf_options = {})
      pdf = PDF::HTMLDoc.new
      pdf_options = { :bodycolor => :white,
                      :toc => false,
                      :portrait => true,
                      :links => false,
                      :webpage => true,
                      :left => '2cm',
                      :right => '2cm' }.merge(pdf_options)
      pdf_options.each do |opt,val|
        pdf.set_option opt, val
      end
      data = render_to_string(options)
      pdf << data
      options[:filename] = File.basename(filename, ".pdf") + ".pdf"
      options[:type] = 'application/pdf'
      options[:disposition] = 'inline' unless options[:disposition]
      send_data(pdf.generate, options)
    end
    
  end
end



class String
  
  # Wraps all instances of symbols in an HTML <tt><font face="Symbol"></tt> tag so that symbols are properly displayed
  # when generating PDFs using HTMLDOC. If you'd like to just get the symbol returned, specify :symbol_only => true.
  def pdf_symbol_fontize(options = {})
    options = { :prefix => "<font face=\"Symbol\">", :suffix => "&nbsp;&nbsp;&nbsp;</font>" }.merge(options)
    chars = { "&iexcl;" => "", "&cent;" => "", "&pound;" => "", "&curren;" => "", "&yen;" => "", "&brvbar;" => "", "&sect;" => "", "&uml;" => "", "&copy;" => "&#211;", "&ordf;" => "", "&laquo;" => "", "&not;" => "&#216;", "&shy;" => "", "&reg;" => "&#210;", "&macr;" => "", "&deg;" => "", "&plusmn;" => "&#177;", "&sup2;" => "", "&sup3;" => "", "&acute;" => "", "&micro;" => "", "&para;" => "", "&middot;" => "", "&cedil;" => "", "&sup1;" => "", "&ordm;" => "\272", "&raquo;" => "", "&frac14;" => "", "&frac12;" => "", "&frac34;" => "", "&iquest;" => "", "&Agrave;" => "", "&Aacute;" => "", "&Acirc;" => "", "&Atilde;" => "", "&Auml;" => "", "&Aring;" => "", "&AElig;" => "", "&Ccedil;" => "", "&Egrave;" => "", "&Eacute;" => "", "&Ecirc;" => "", "&Euml;" => "", "&Igrave;" => "", "&Iacute;" => "", "&Icirc;" => "", "&Iuml;" => "", "&ETH;" => "", "&Ntilde;" => "", "&Ograve;" => "", "&Oacute;" => "", "&Ocirc;" => "", "&Otilde;" => "", "&Ouml;" => "", "&times;" => "&#180;", "&Oslash;" => "", "&Ugrave;" => "", "&Uacute;" => "", "&Ucirc;" => "", "&Uuml;" => "", "&Yacute;" => "", "&THORN;" => "", "&szlig;" => "", "&agrave;" => "", "&aacute;" => "", "&acirc;" => "", "&atilde;" => "", "&auml;" => "", "&aring;" => "", "&aelig;" => "", "&ccedil;" => "", "&egrave;" => "", "&eacute;" => "", "&ecirc;" => "", "&euml;" => "", "&igrave;" => "", "&iacute;" => "", "&icirc;" => "", "&iuml;" => "", "&eth;" => "", "&ntilde;" => "", "&ograve;" => "", "&oacute;" => "", "&ocirc;" => "", "&otilde;" => "", "&ouml;" => "", "&divide;" => "&#184;", "&oslash;" => "", "&ugrave;" => "", "&uacute;" => "", "&ucirc;" => "", "&uuml;" => "", "&yacute;" => "", "&thorn;" => "", "&yuml;" => "", "&fnof;" => "&#166;", "&bull;" => "", "&hellip;" => "&#188;", "&prime;" => "&#162;", "&Prime;" => "&#178;", "&oline;" => "", "&frasl;" => "&#164;", "&image;" => "&#193;", "&weierp;" => "&#195;", "&real;" => "&#194;", "&trade;" => "&#212;", "&alefsym;" => "&#192;", "&larr;" => "&#172;", "&uarr;" => "&#173;", "&rarr;" => "&#174;", "&darr;" => "&#175;", "&harr;" => "&#171;", "&crarr;" => "&#191;", "&lArr;" => "&#220;", "&uArr;" => "&#221;", "&rArr;" => "&#222;", "&dArr;" => "&#223;", "&hArr;" => "&#219;", "&forall;" => "&#34;", "&part;" => "&#182;", "&exist;" => "&#36;", "&empty;" => "&#198;", "&nabla;" => "&#209;", "&isin;" => "&#206;", "&notin;" => "&#207;", "&ni;" => "&#39;", "&prod;" => "&#213;", "&sum;" => "&#229;", "&minus;" => "&#45;", "&lowast;" => "&#42;", "&radic;" => "&#214;", "&prop;" => "&#181;", "&infin;" => "&#165;", "&ang;" => "&#208;", "&and;" => "", "&or;" => "", "&cap;" => "&#199;", "&cup;" => "&#200;", "&int;" => "&#242;", "&there4;" => "&#92;", "&sim;" => "&#126;", "&cong;" => "&#64;", "&asymp;" => "&#187;", "&ne;" => "&#185;", "&equiv;" => "&#186;", "&le;" => "&#163;", "&ge;" => "&#179;", "&sub;" => "&#204;", "&sup;" => "&#201;", "&nsub;" => "&#203;", "&sube;" => "&#205;", "&supe;" => "&#202;", "&oplus;" => "&#197;", "&otimes;" => "&#196;", "&perp;" => "&#94;", "&sdot;" => "&#215;", "&lceil;" => "&#233;", "&rceil;" => "&#249;", "&lfloor;" => "&#235;", "&rfloor;" => "&#251;", "&lang;" => "&#237;", "&rang;" => "&#253;", "&Alpha;" => "A", "&Beta;" => "B", "&Gamma;" => "G", "&Delta;" => "D", "&Epsilon;" => "E", "&Zeta;" => "Z", "&Eta;" => "H", "&Theta;" => "Q", "&Iota;" => "I", "&Kappa;" => "K", "&Lambda;" => "L", "&Mu;" => "M", "&Nu;" => "N", "&Xi;" => "X", "&Omicron;" => "O", "&Pi;" => "P", "&Rho;" => "R", "&Sigma;" => "S", "&Tau;" => "T", "&Upsilon;" => "U", "&Phi;" => "F", "&Chi;" => "C", "&Psi;" => "Y", "&Omega;" => "W", "&alpha;" => "a", "&beta;" => "b", "&gamma;" => "g", "&delta;" => "d", "&epsilon;" => "e", "&zeta;" => "z", "&eta;" => "h", "&theta;" => "q", "&iota;" => "i", "&kappa;" => "k", "&lambda;" => "l", "&mu;" => "m", "&nu;" => "n", "&xi;" => "x", "&omicron;" => "o", "&pi;" => "p", "&rho;" => "r", "&sigmaf;" => "V", "&sigma;" => "s", "&tau;" => "t", "&upsilon;" => "u", "&phi;" => "f", "&chi;" => "c", "&loz;" => "&#224;", "&psi;" => "y", "&omega;" => "w", "&thetasym;" => "J", "&upsih;" => "&#161;", "&piv;" => "v", "&#161;" => "", "&#162;" => "", "&#163;" => "", "&#164;" => "", "&#165;" => "", "&#166;" => "", "&#167;" => "", "&#168;" => "", "&#169;" => "&#211;", "&#170;" => "", "&#171;" => "", "&#172;" => "&#216;", "&#173;" => "", "&#174;" => "&#210;", "&#175;" => "", "&#176;" => "", "&#177;" => "&#177;", "&#178;" => "", "&#179;" => "", "&#180;" => "", "&#181;" => "", "&#182;" => "", "&#183;" => "", "&#184;" => "", "&#185;" => "", "&#186;" => "", "&#187;" => "", "&#188;" => "", "&#189;" => "", "&#190;" => "", "&#191;" => "", "&#192;" => "", "&#193;" => "", "&#194;" => "", "&#195;" => "", "&#196;" => "", "&#197;" => "", "&#198;" => "", "&#199;" => "", "&#200;" => "", "&#201;" => "", "&#202;" => "", "&#203;" => "", "&#204;" => "", "&#205;" => "", "&#206;" => "", "&#207;" => "", "&#208;" => "", "&#209;" => "", "&#210;" => "", "&#211;" => "", "&#212;" => "", "&#213;" => "", "&#214;" => "", "&#215;" => "&#180;", "&#216;" => "", "&#217;" => "", "&#218;" => "", "&#219;" => "", "&#220;" => "", "&#221;" => "", "&#222;" => "", "&#223;" => "", "&#224;" => "", "&#225;" => "", "&#226;" => "", "&#227;" => "", "&#228;" => "", "&#229;" => "", "&#230;" => "", "&#231;" => "", "&#232;" => "", "&#233;" => "", "&#234;" => "", "&#235;" => "", "&#236;" => "", "&#237;" => "", "&#238;" => "", "&#239;" => "", "&#240;" => "", "&#241;" => "", "&#242;" => "", "&#243;" => "", "&#244;" => "", "&#245;" => "", "&#246;" => "", "&#247;" => "&#184;", "&#248;" => "", "&#249;" => "", "&#250;" => "", "&#251;" => "", "&#252;" => "", "&#253;" => "", "&#254;" => "", "&#255;" => "", "&#402;" => "&#166;", "&#8226;" => "", "&#8230;" => "&#188;", "&#8242;" => "&#162;", "&#8243;" => "&#178;", "&#8254;" => "", "&#8260;" => "&#164;", "&#8465;" => "&#193;", "&#8472;" => "&#195;", "&#8476;" => "&#194;", "&#8482;" => "&#212;", "&#8501;" => "&#192;", "&#8592;" => "&#172;", "&#8593;" => "&#173;", "&#8594;" => "&#174;", "&#8595;" => "&#175;", "&#8596;" => "&#171;", "&#8629;" => "&#191;", "&#8656;" => "&#220;", "&#8657;" => "&#221;", "&#8658;" => "&#222;", "&#8659;" => "&#223;", "&#8660;" => "&#219;", "&#8704;" => "&#34;", "&#8706;" => "&#182;", "&#8707;" => "&#36;", "&#8709;" => "&#198;", "&#8711;" => "&#209;", "&#8712;" => "&#206;", "&#8713;" => "&#207;", "&#8715;" => "&#39;", "&#8719;" => "&#213;", "&#8721;" => "&#229;", "&#8722;" => "&#45;", "&#8727;" => "&#42;", "&#8730;" => "&#214;", "&#8733;" => "&#181;", "&#8734;" => "&#165;", "&#8736;" => "&#208;", "&#8743;" => "", "&#8744;" => "", "&#8745;" => "&#199;", "&#8746;" => "&#200;", "&#8747;" => "&#242;", "&#8756;" => "&#92;", "&#8764;" => "&#126;", "&#8773;" => "&#64;", "&#8776;" => "&#187;", "&#8800;" => "&#185;", "&#8801;" => "&#186;", "&#8804;" => "&#163;", "&#8805;" => "&#179;", "&#8834;" => "&#204;", "&#8835;" => "&#201;", "&#8836;" => "&#203;", "&#8838;" => "&#205;", "&#8839;" => "&#202;", "&#8853;" => "&#197;", "&#8855;" => "&#196;", "&#8869;" => "&#94;", "&#8901;" => "&#215;", "&#8968;" => "&#233;", "&#8969;" => "&#249;", "&#8970;" => "&#235;", "&#8971;" => "&#251;", "&#9001;" => "&#237;", "&#9002;" => "&#253;", "&#913;" => "A", "&#914;" => "B", "&#915;" => "G", "&#916;" => "D", "&#917;" => "E", "&#918;" => "Z", "&#919;" => "H", "&#920;" => "Q", "&#921;" => "I", "&#922;" => "K", "&#923;" => "L", "&#924;" => "M", "&#925;" => "N", "&#926;" => "X", "&#927;" => "O", "&#928;" => "P", "&#929;" => "R", "&#931;" => "S", "&#932;" => "T", "&#933;" => "U", "&#934;" => "F", "&#935;" => "C", "&#936;" => "Y", "&#937;" => "W", "&#945;" => "a", "&#946;" => "b", "&#947;" => "g", "&#948;" => "d", "&#949;" => "e", "&#950;" => "z", "&#951;" => "h", "&#952;" => "q", "&#953;" => "i", "&#954;" => "k", "&#955;" => "l", "&#956;" => "m", "&#957;" => "n", "&#958;" => "x", "&#959;" => "o", "&#960;" => "p", "&#961;" => "r", "&#962;" => "V", "&#963;" => "s", "&#964;" => "t", "&#965;" => "u", "&#966;" => "f", "&#967;" => "c", "&#9674;" => "&#224;", "&#968;" => "y", "&#969;" => "w", "&#977;" => "J", "&#978;" => "&#161;", "&#982;" => "v" }
    text = self
    chars.each do |char, symbol|
      new_chunk = options[:symbol_only] == true ? symbol : "#{options[:prefix]}#{symbol}#{options[:suffix]}"
      text = text.gsub(char, new_chunk) unless symbol.blank?
    end
    text
  end
  
  def to_pdf_octals(options = {})
    chars = { "A" => "\101","&AElig;" => "\306","&Aacute;" => "\301","&Acirc;" => "\302","&Auml;" => "\304","&Agrave;" => "\300","&Aring;" => "\305","&Atilde;" => "\303","B" => "\102","C" => "\103","&Ccedil;" => "\307","D" => "\104","E" => "\105","&Eacute;" => "\311","&Ecirc;" => "\312","&Euml;" => "\313","&Egrave;" => "\310","&ETH;" => "\320","&euro;" => "\200","F" => "\106","G" => "\107","H" => "\110","I" => "\111","&Iacute;" => "\315","&Icirc;" => "\316","&Iuml;" => "\317","&Igrave;" => "\314","J" => "\112","K" => "\113","L" => "\114","M" => "\115","N" => "\116","&Ntilde;" => "\321","O" => "\117","&OElig;" => "\214","&Oacute;" => "\323","&Ocirc;" => "\324","&Ouml;" => "\326","&Ograve;" => "\322","&Oslash;" => "\330","&Otilde;" => "\325","P" => "\120","Q" => "\121","R" => "\122","S" => "\123","&Scaron;" => "\212","T" => "\124","&THORN;" => "\336","U" => "\125","&Uacute;" => "\332","&Ucirc;" => "\333","&Uuml;" => "\334","&Ugrave;" => "\331","V" => "\126","W" => "\127","X" => "\130","Y" => "\131","&Yacute;" => "\335","&Yuml;" => "\237","Z" => "\132","&#x17D;" => "\216","a" => "\141","&aacute;" => "\341","&acirc;" => "\342","&acute;" => "\264","&auml;" => "\344","&aelig;" => "\346","&agrave;" => "\340","&amp;" => "\046","&aring;" => "\345","^" => "\136","~" => "\176","*" => "\52","@" => "\100","&atilde;" => "\343","b" => "\142","\\" => "\134","|" => "\174","{" => "\173","}" => "\175","[" => "\133","]" => "\135","&brvbar;" => "\246","&bull;" => "\225","c" => "\143","&ccedil;" => "\347","&cedil;" => "\270","&cent;" => "\242","&circ;" => "\210",":" => "\72","," => "\54","&copy;" => "\251","&curren;" => "\244","d" => "\144","&dagger;" => "\206","&Dagger;" => "\207","&deg;" => "\260","&uml;" => "\250","&divide;" => "\367","$" => "\44","e" => "\145","&eacute;" => "\351","&ecirc;" => "\352","&euml;" => "\353","&egrave;" => "\350","8" => "\70","&hellip;" => "\205","&mdash;" => "\227","&ndash;" => "\226","=" => "\75","&eth;" => "\360","!" => "\41","&iexcl;" => "\241","f" => "\146","5" => "\65","&fnof;" => "\203","4" => "\64","g" => "\147","&szlig;" => "\337","`" => "\140","&gt;" => "\76","&laquo;" => "\253","&raquo;" => "\273","&lsaquo;" => "\213","&rsaquo;" => "\233","h" => "\150","-" => "\55","i" => "\151","&iacute;" => "\355","&icirc;" => "\356","&iuml;" => "\357","&igrave;" => "\354","j" => "\152","k" => "\153","l" => "\154","&lt;" => "\074","&not;" => "\254","m" => "\155","&macr;" => "\257","&micro;" => "\265","&times;" => "\327","n" => "\156","9" => "\071","&ntilde;" => "\361","#" => "\043","o" => "\157","&oacute;" => "\363","&ocirc;" => "\364","&ouml;" => "\366","&oelig;" => "\234","&ograve;" => "\362","1" => "\061","&frac12;" => "\275","&frac14;" => "\274","&sup1;" => "\271","&ordf;" => "\252","&ordm;" => "\272","&oslash;" => "\370","&otilde;" => "\365","p" => "\160","&para;" => "\266","(" => "\050",")" => "\051","%" => "\045","." => "\056","&middot;" => "\267","&permil;" => "\211","+" => "\053","&plusmn;" => "\261","q" => "\161","?" => "\077","&iquest;" => "\277","&quot;" => "\042","&bdquo;" => "\204","&ldquo;" => "\223","&rdquo;" => "\224","&lsquo;" => "\221","&rsquo;" => "\222","&sbquo;" => "\202","&#x27;" => "\047","r" => "\162","&reg;" => "\256","s" => "\163","&scaron;" => "\232","&sect;" => "\247",";" => "\073","7" => "\067","6" => "\066","/" => "\057","" => "\040","&pound;" => "\243","t" => "\164","&thorn;" => "\376","3" => "\063","&frac34;" => "\276","&sup3;" => "\263","&tilde;" => "\230","&trade;" => "\231","2" => "\062","&sup2;" => "\262","u" => "\165","&uacute;" => "\372","&ucirc;" => "\373","&uuml;" => "\374","&ugrave;" => "\371","_" => "\137","v" => "\166","w" => "\167","x" => "\170","y" => "\171","&yacute;" => "\375","&yuml;" => "\377","&yen;" => "\245","z" => "\172","&#x17E;" => "\236","0" => "\060","&nbsp;" => "\240" }
    text = self
    chars.each do |char, symbol|
      text = text.gsub(char, symbol) unless symbol.blank?
    end
    text
  end

end