require File.dirname(__FILE__) + '/../spec_helper'

describe <%= plural_class_name %>Controller do
  integrate_views
  
	  <%= controller_methods 'tests/rspec/actions' %>
end
