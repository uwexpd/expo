# PDF templating
require 'pdf_render'
ActionView::Template::register_template_handler 'pdfw', ActionView::PDFRender
ActionController::Base.exempt_from_layout :pdfw
#ActionView::Template.register_template_handler 'htmldoc', ActionView::HTMLDocPDFRender

#ActionView::Template::register_template_handler 'rtex', RTeX::Document

require "#{RAILS_ROOT}/lib/rtex/document.rb"