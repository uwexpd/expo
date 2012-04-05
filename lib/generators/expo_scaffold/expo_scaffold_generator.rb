class ExpoScaffoldGenerator < Rails::Generator::Base
  attr_accessor :name, :attributes, :controller_actions
  
  def initialize(runtime_args, runtime_options = {})
    super
    usage if @args.empty?
    
    @name = @args.first
    @controller_actions = []
    @attributes = []
    
    @args[1..-1].each do |arg|
      if arg == '!'
        options[:invert] = true
      elsif arg.include? ':'
        @attributes << Rails::Generator::GeneratedAttribute.new(*arg.split(":"))
      else
        @controller_actions << arg
        @controller_actions << 'create' if arg == 'new'
        @controller_actions << 'update' if arg == 'edit'
      end
    end
    
    @controller_actions.uniq!
    @attributes.uniq!
    
    if options[:invert] || @controller_actions.empty?
      @controller_actions = all_actions - @controller_actions
    end
    
    if @attributes.empty?
      options[:skip_model] = true # default to skipping model if no attributes passed
      if model_exists?
        model_columns_for_attributes.each do |column|
          @attributes << Rails::Generator::GeneratedAttribute.new(column.name.to_s, column.type.to_s)
        end
      else
        @attributes << Rails::Generator::GeneratedAttribute.new('name', 'string')
      end
    end
  end
  
  def manifest
    record do |m|
      unless options[:skip_model]
        m.directory "app/models"
        m.template "model.rb", "app/models/#{singular_name}.rb"
        unless options[:skip_migration]
          m.migration_template "migration.rb", "db/migrate", :migration_file_name => "create_#{plural_name}"
        end
        
        if rspec?
          m.directory "spec/models"
          m.template "tests/#{test_framework}/model.rb", verify_file_path("spec/models/#{singular_name}_spec.rb")
          m.directory "spec/factories"
          m.template "tests/#{test_framework}/factory.rb", verify_file_path("spec/factories/#{singular_name}_factory.rb")
        else
          m.directory "test/unit"
          m.template "tests/#{test_framework}/model.rb", verify_file_path("test/unit/#{singular_name}_test.rb")
          m.directory "test/fixtures"
          m.template "fixtures.yml", verify_file_path("test/fixtures/#{plural_path_name}.yml")
        end
      end
      
      unless options[:skip_controller]
        m.directory "app/controllers"
        m.template "controller.rb", verify_file_path("app/controllers/#{plural_path_name}_controller.rb")
        
        # m.directory "app/helpers"
        # m.template "helper.rb", verify_file_path("app/helpers/#{plural_path_name}_helper.rb")
        
        m.directory "app/views/#{plural_path_name}"
        controller_actions.each do |action|
          if File.exist? source_path("views/#{view_language}/#{action}.html.#{view_language}")
            m.template "views/#{view_language}/#{action}.html.#{view_language}",
                      verify_file_path("app/views/#{plural_path_name}/#{action}.html.#{view_language}")
          end
        end
        
        if File.exist? source_path("views/rjs/destroy.js.rjs")
          m.template "views/rjs/destroy.js.rjs", verify_file_path("app/views/#{plural_path_name}/destroy.js.rjs")
        end
      
        if form_partial?
          m.template "views/#{view_language}/_fields.html.#{view_language}", verify_file_path("app/views/#{plural_path_name}/_fields.html.#{view_language}")
        end
      
        unless options[:skip_route]
          m.route_resources plural_name
        end
        
        if rspec?
          m.directory "spec/controllers"
          m.template "tests/#{test_framework}/controller.rb", verify_file_path("spec/controllers/#{plural_path_name}_controller_spec.rb")
        else
          m.directory "test/functional"
          m.template "tests/#{test_framework}/controller.rb", verify_file_path("test/functional/#{plural_path_name}_controller_test.rb")
        end
      end
    end
  end
  
  def form_partial?
    actions? :new, :edit
  end
  
  def all_actions
    %w[index show new create edit update destroy]
  end
  
  def action?(name)
    controller_actions.include? name.to_s
  end
  
  def actions?(*names)
    names.all? { |n| action? n.to_s }
  end
  
  def singular_name
    (name.include?('::') ? name.split('::').last : name).underscore
  end
  
  def plural_name
    singular_name.pluralize
  end
  
  def plural_path_name
    name.underscore.pluralize
  end
  
  def parent_name
    name.include?('::') ? name.split('::')[name.split('::').size-2].underscore.singularize : nil
  end
  
  def name_pieces(include_admin = false)
    pieces = name.split('::')
    pieces.delete "Admin" unless include_admin
    pieces
  end
  
  def class_name
    name.camelize
  end
  
  # Tries to guess the model name from the info passed in the arguments. Strips "Admin::" off the front if it exists
  # and then removes namespacing and singularizes each element. So "Admin::Offerings::Restrictions::Exemption"
  # becomes "OfferingRestrictionExemption".
  def model_name
    name_pieces(false).collect{ |n| n.singularize.camelize }.join('')
  end
  
  def parent_class_name
    parent_name.singularize.camelize
  end
  
  def parent_object
    return name unless parent_name
    if name_pieces[-3]
      "@#{name_pieces[-3].underscore.singularize}.#{name_pieces[-2].underscore.pluralize}"
    else
      parent_class_name
    end
  end
  
  def controller_superclass
    (parent_name ? name_pieces(true)[0..(name_pieces.size-1)].join('::').camelize : "Application") + "Controller"
  end
  
  # If this is a namespaced controller, return something like "@parent.things"
  # If not, just return "Thing".
  def collection_class_name
    parent_name ? "@#{parent_name.singularize}.#{plural_name}" : class_name
  end
  
  def plural_class_name
    plural_name.camelize
  end
  
  def controller_methods(dir_name)
    controller_actions.map do |action|
      read_template("#{dir_name}/#{action}.rb")
    end.join("  \n").strip
  end
  
  def render_form
    if form_partial?
      if options[:haml]
        "= render :partial => 'form'"
      else
        "<%= render :partial => 'form' %>"
      end
    else
      read_template("views/#{view_language}/_fields.html.#{view_language}")
    end
  end
  
  def items_path(suffix = 'path')
    if parent_name
      str = name_pieces.collect{|s| s.underscore.singularize }.join("_")
      str << "s_#{suffix}("
      str << name_pieces[0..(name_pieces.size-2)].collect{|s| "@#{s.underscore.singularize}"}.join(", ")
      str << ")"
    else
      "#{plural_name}_#{suffix}"
    end
  end
  
  def item_path(suffix = 'path', prefix = nil, include_object = true, object_is_instance_variable = true)
    if parent_name
      str = ""
      str << prefix.to_s + "_" if prefix
      str << name_pieces.collect{|s| s.underscore.singularize }.join("_")
      str << "_#{suffix}("
      str << name_pieces[0..(name_pieces.size-2)].collect{|s| "@#{s.underscore.singularize}"}.join(", ")
      str << ", #{'@' if object_is_instance_variable}#{singular_name}" if include_object
      str << ")"
    else
      "@#{singular_name}"
    end
  end
  
  def new_path(object_is_instance_variable = false, suffix = 'path')
    item_path(suffix, :new, false, object_is_instance_variable)
  end

  def edit_path(object_is_instance_variable = false, suffix = 'path')
    item_path(suffix, :edit, true, object_is_instance_variable)
  end

  def show_path(object_is_instance_variable = false, suffix = 'path')
    item_path(suffix, nil, true, object_is_instance_variable)
  end
  
  def parent_path(suffix = 'path')
    if parent_name
      name_pieces.pop
      str = name_pieces[0..(name_pieces.size-2)].collect{|s| "#{s.underscore.singularize}"}.join("_")
      str << "_#{suffix}("
      str << name_pieces[0..(name_pieces.size-2)].collect{|s| "@#{s.underscore.singularize}"}.join(", ")
      str << ")"
    else
      "@#{parent_name}"
    end
  end
  
  def item_path_for_spec(suffix = 'path')
    if action? :show
      "#{singular_name}_#{suffix}(assigns[:#{singular_name}])"
    else
      items_path(suffix)
    end
  end
  
  def item_path_for_test(suffix = 'path')
    if action? :show
      "#{singular_name}_#{suffix}(assigns(:#{singular_name}))"
    else
      items_path(suffix)
    end
  end
  
  def model_columns_for_attributes
    model_name.constantize.columns.reject do |column|
      column.name.to_s =~ /^(id|created_at|updated_at|creator_id|updater_id|deleter_id)$/
    end
  end
  
  def rspec?
    test_framework == :rspec
  end
  
protected
  
  def view_language
    options[:haml] ? 'haml' : 'erb'
  end
  
  def test_framework
    options[:test_framework] ||= default_test_framework
  end
  
  def default_test_framework
    File.exist?(destination_path("spec")) ? :rspec : :testunit
  end
  
  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("--skip-model", "Don't generate a model or migration file.") { |v| options[:skip_model] = v }
    opt.on("--skip-migration", "Don't generate migration file for model.") { |v| options[:skip_migration] = v }
    opt.on("--skip-timestamps", "Don't add timestamps to migration file.") { |v| options[:skip_timestamps] = v }
    opt.on("--skip-controller", "Don't generate controller, helper, or views.") { |v| options[:skip_controller] = v }
    opt.on("--invert", "Generate all controller actions except these mentioned.") { |v| options[:invert] = v }
    opt.on("--haml", "Generate HAML views instead of ERB.") { |v| options[:haml] = v }
    opt.on("--testunit", "Use test/unit for test files.") { options[:test_framework] = :testunit }
    opt.on("--rspec", "Use RSpec for test files.") { options[:test_framework] = :rspec }
    opt.on("--shoulda", "Use Shoulda for test files.") { options[:test_framework] = :shoulda }
  end
  
  # is there a better way to do this? Perhaps with const_defined?
  def model_exists?
    puts "Trying model " + model_name.constantize.to_s
    exists = Object.const_defined?(model_name.to_sym)
    puts exists ? "*** Model exists" : "*** Model #{model_name.to_s} DOES NOT exist"
    exists
  end
  
  def read_template(relative_path)
    ERB.new(File.read(source_path(relative_path)), nil, '-').result(binding)
  end

  # Verifies that the directories leading up to this filename exist, or if they don't, creates them.
  def verify_file_path(file)
    FileUtils.mkdir_p(File.dirname(file)) unless File.exists?(File.dirname(file))
    file
  end

  
  def banner
    <<-EOS
Creates a controller and optional model given the name, actions, and attributes.

USAGE: #{$0} #{spec.name} ModelName [controller_actions and model:attributes] [options]
EOS
  end
end
