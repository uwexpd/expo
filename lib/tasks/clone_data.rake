namespace :db do
  desc "Clone the data associated with a model from the production database to the development database directly (without callbacks).\n\n" + 
       "      # If the development database contains any data related to the model, it is purged before the copy is made.\n" +
       "      # Specify the model class name on the command line as MODEL=X,Y,Z (no spaces)\n" + 
       "      # If MODEL is omitted, all models that do not inherit from StudentInfo will be used\n" +
       "      # Specify the model classes to NOT include on the command line as EXCEPT=C,D,E (no spaces)\n" +
       "      # Source database as SOURCE=db (production by default)\n" +
       "      # Destination database as DESTINATION=db  (development by default)\n\n" +       
       "      # To disable batch mode BATCH=N (batch mode is on by default)\n" +
       "      # e.g. rake db:clone_data MODEL=User,Account,Post BATCH=Y\n"
  task :direct_clone_data => :environment do

    puts "Loaded #{RAILS_ENV} environment."

    STDOUT.sync = true
    cr = "\r"
    clear = "\e[0K"
    reset = cr + clear
    
    batchmode = ENV['BATCH'] ? !(ENV['BATCH'] =~ /^n$/i) : true
    sourcedb = ENV['SOURCE'] || 'production'
    destdb = ENV['DESTINATION'] || 'development'
    puts "Connecting to source database: '#{sourcedb}'"
    ActiveRecord::Base.establish_connection(sourcedb)

    # Collect the models to process
  	unless ENV['MODEL']
  	  print "\nLoading all models: "
  	  Dir.glob(RAILS_ROOT + '/app/models/**/*.rb').each { |file| require file; print "." }
  	  models = Object.subclasses_of(ActiveRecord::Base)
  	  lmodels = models.reject{|m| StudentInfo.send(:subclasses).include?(m) || m==StudentInfo || m.to_s.include?("CGI::")}
      model_names = lmodels.collect(&:to_s)
      model_names = model_names.reject{|m| ENV['EXCEPT'].split(/,/).include?(m.to_s)} if ENV['EXCEPT']
      puts "\n"
    else		  	  
      model_names = ENV['MODEL'].strip.split(/,/)
    end
  
    # Continue with processing?
    puts "Cloning #{model_names.size} models from '#{sourcedb}' to '#{destdb}'."
    model_names.sort!
    # puts model_names.collect(&:to_s).join(", ")
    print "\nCollect data from #{sourcedb} database? [Y|n]: "
    Process.exit if $stdin.gets.strip =~ /^n/i

    # Loop through each model
    data = {}
    print "\nCollecting data from #{sourcedb} database:"
  	for model_name in model_names
  
      begin
        klass = model_name.constantize
      rescue
        raise "ERROR: Unable to get a Class object corresponding to #{model_name}. Check if you specified the correct model name: #{$!}"
      end

      # unless klass.superclass == ActiveRecord::Base
      #   raise "ERROR: #{model_name}.superclass (#{klass.superclass}) is not ActiveRecord::Base"
      # end

      # Collect all the data from the source database
      print "\n    #{model_name.rjust(45)}:  "
      data[model_name] = klass.find(:all)
      print "#{data[model_name].length.to_s}"

      unless batchmode
        print "\n    Do you want to see a yaml dump? [y|N]: "
        if $stdin.gets.strip =~ /^y/i
          puts data[model_name].to_yaml	
        end
        print "\n    Do you want to direct the yaml dump to a file? [y|N]: "
        if $stdin.gets.strip =~ /^n/i
          print "\n    Please specify the file name : "
          File.open($stdin.gets.strip, 'w') do |f|
            f.write data[model_name].to_yaml
          end
        end
      end
    end

    print "\n\nReplace records in #{destdb} database? [Y|n]: "
    Process.exit if $stdin.gets.strip =~ /^n/i

    puts "\nConnecting to destination database: '#{destdb}'"
    ActiveRecord::Base.establish_connection(destdb)

    for model_name in data.keys.sort

      klass = model_name.constantize
      olddata = klass.find(:all)

      print "\n    #{model_name}"

      unless batchmode
        print "Do you want to see a yaml dump? [y|N]: "
        if $stdin.gets.strip =~ /^y/i
          puts olddata.to_yaml	
        end
      end

      print "\n        Deleting #{olddata.length} old records "
      i = 0
      for f in olddata
        i = i+1
        print "#{cr}        Deleting record #{i.to_s} of #{olddata.length}"
        f.destroy_without_callbacks  # We disable callbacks so that Rails doesn't try to delete dependent records.
      end

      print "\n        Creating #{data[model_name].length.to_s} new records: "
      i = 0
      for d in data[model_name]
        begin
          i = i+1
          print "#{cr}        Creating record #{i.to_s} of #{data[model_name].length.to_s}"
          obj = klass.new d.attributes
          obj.id = d.id
          unless obj.send :create_without_callbacks # We force the create without callbacks so that Rails doesn't run any before_save, etc.
            raise "Unable to save obj #{d.id}"
          end
        rescue Exception => e
      	  puts e.message
      	  puts e.backtrace.inspect
          raise "Error saving model data: #{$!}"
        end
      end
    end

    puts "\n\nDone."

    end

  end

