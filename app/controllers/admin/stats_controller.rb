# TODO
# General (from SDB):
# breakdown by high school attended (with ceeb code)
# breakdown by residency status
# breakdown by home states
# breakdown by majors
# breakdown by ethnicities
# breakdown by class standing
# breakdown by application type
# number of transfer students
# number of under-represented students
# number of EOP1 students
# average age
# 
# DP-specific:
# number of active quarters
# grade level when entered
# high school attending
class Admin::StatsController < Admin::BaseController

  before_filter :add_to_breadcrumbs
  uses_charts
  
  def index
    redirect_to :action => "query"
  end

  def query
    session[:breadcrumbs].add "Query"
  end

  def population
    @population = Population.find params[:id]
    @title = @population.title
    generate_results(@population.objects)
    session[:breadcrumbs].add "#{@title}", population_path(@population)
    session[:breadcrumbs].add "Results"

    respond_to do |format|
      format.html { render :action => 'result' }
      format.xls { render :action => 'result', :layout => 'basic' } # result.xls.erb
    end
  end
  caches_action :population

  def resolve_conflicts
    return redirect_to :action => "query" if params[:q].blank?
    
    if params[:commit] == 'Proceed'
      @found = StudentRecord.find(params[:found].split(","))
      @not_found = params[:not_found].strip.split(/[\r\n]/)
      @conflicts = {}
      remaining_conflicts = params[:conflicts].strip.split(/[\r\n]/)
      params[:conflict_removals].each{|q| remaining_conflicts.delete(q)}
      if params[:conflict_resolutions]
        for q, new_system_key in params[:conflict_resolutions]
          remaining_conflicts.delete(q)
          @found << StudentRecord.find(new_system_key)
        end
      end
      populate_conflict_arrays(remaining_conflicts)
    else
      @found = []
      @not_found = []
      @conflicts = {}
      populate_conflict_arrays(params[:q].strip.split(/[\r\n]/))
    end
    
    if @conflicts.empty? && (@not_found.empty? || params[:commit] == 'Proceed')
      p = ManualPopulation.new
      p.title = params[:title].blank? ? "Manual Student Query #{Time.now.to_i.to_s}" : params[:title]
      p.access_level = 'creator'
      p.creator_id = current_user.try(:id)
      p.system = true if params[:title].blank?
      p.object_ids = {}
      @found.each do |r|
        p.object_ids[r.class.to_s.to_sym] ||= []
        p.object_ids[r.class.to_s.to_sym] << r.id
      end
      until p.valid? && !p.errors.on(:title)
        if p.title[/\d+$/].nil?
          p.title += " 2"
        else
          new_num = p.title[/\d+$/].to_i + 1
          p.title.gsub!(/\d+$/, new_num.to_s)
        end
      end
      if p.save
        redirect_to population_url(p)
      else
        flash[:error] = "There was an error saving your query."
      end
    end
  end

  def result
    generate_results(params[:stats][:students].split)
    session[:breadcrumbs].add "Results"
    @title = params[:stats][:title]
 
    respond_to do |format|
      format.html # result.html.erb
      format.xls { render :action => 'result', :layout => 'basic' } # result.xls.erb
    end
  end
  
  def overview
    @start_quarter = Quarter.find(params[:start_quarter_id] || Quarter.current_quarter.prev.prev.prev.prev.id)
    @end_quarter = Quarter.find(params[:end_quarter_id] || Quarter.current_quarter.id)
    @students_only = !params[:students_only].nil? ? true : false
    @quarters = []
    q = @start_quarter
    while q <= @end_quarter
      @quarters << q
      q = q.next
    end
    session[:breadcrumbs].add "Participation Overview"
    
    respond_to do |format|
      format.html
      format.js { render :partial => 'admin/stats/overview/data_table' }
    end
  end

  protected
  
  def add_to_breadcrumbs
    session[:breadcrumbs].add "Stats", "/admin/stats"
  end
  
  def populate_conflict_arrays(collection)
    for q in collection
      next if q.strip.blank?
      if q.strip.include?(" ") || q.include?(",") # treat this as a full name search
        sr = StudentRecord.find_by_name(q, 15, false, true)
      elsif q.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/)
        sr = StudentRecord.find_by_student_no("#{q}")
      else
        sr = StudentRecord.find_by_uw_netid("#{q}")
      end
    
      if sr.nil? || (sr.is_a?(Array) && sr.empty?)
        @not_found << q
      elsif sr.is_a?(Array) && sr.size > 1
        @conflicts[q] = [sr].flatten
      elsif sr.is_a?(Array) && sr.size == 1
        @found << sr.first
      else
        @found << sr
      end
    end
  end

  def generate_results(collection)
    @students = Array.new
    @duplicate_count = 0
    @errors = Array.new; @under_rep_students = Array.new; @eop_students = Array.new; @ethnicities = Hash.new
    @hispanics = Hash.new; @ages = Hash.new; @genders = Hash.new; @discipline_categories = Hash.new
    collection.each do |n|
      if n.is_a?(Student)
        student_to_add = n
      elsif n.respond_to?(:person) || n.respond_to?(:student)
        if n.person.is_a?(Student)
          student_to_add = n.person
        else
          @errors << n
        end
      elsif n.is_a?(String)
        n = n.strip
        student_to_add = n.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) ? Student.find_by_student_no("#{n}") : Student.find_by_uw_netid("#{n}")
      else
        @errors << n
      end
      if @students.include? student_to_add
        @duplicate_count += 1
      else
        @students << student_to_add unless student_to_add.nil?
        @errors << n if student_to_add.nil? && !n.blank?
      end
    end
    @students.each do |s|
      if s
        @under_rep_students << s if s.sdb.ethnicity.under_represented?
        @eop_students << s if s.sdb.special_program.description == "EOP 1"
        @ethnicities[s.sdb.ethnicity.description] = @ethnicities[s.sdb.ethnicity.description] ? @ethnicities[s.sdb.ethnicity.description]+1 : 1
        @ages[s.age] = @ages[s.age] ? @ages[s.age]+1 : 1
        @genders[s.gender] = @genders[s.gender] ? @genders[s.gender]+1 : 1
        s.sdb.majors.each do |m|
    		  discipline_category = m.discipline_category.nil? ? DisciplineCategory.unknown : m.discipline_category 
    		  if @discipline_categories[discipline_category].nil?
    		    @discipline_categories[discipline_category] = [1,{m.major=>1}]
    		  else # category is there
    		    @discipline_categories[discipline_category][0] += 1
      			@discipline_categories[discipline_category][1][m.major] = @discipline_categories[discipline_category][1][m.major] ?
      			                                                          @discipline_categories[discipline_category][1][m.major]+1 : 1
    		  end
        end
      end
    end
    @student_count = @students.size # - @errors.size
	
	@ethnicities_graph = stats_page_pie_graph(@ethnicities, "Ethnicities")
	@genders_graph = stats_page_pie_graph(@genders, "Genders")
	@majors_graph = majors_graph(@discipline_categories)
  end
  
  def stats_page_pie_graph(values_hash, type)
	color_array = get_colors
	
	title = Title.new("Student #{type}")

	pie = Pie.new
	pie.start_angle = 35
	pie.animate = true
	pie.tooltip = '#val# of #total#<br>#percent# of 100%'
	
	colors = []
	values = []
	values_hash.each do |name, value|
		values << PieValue.new(value,"#{name} (#{value})")
		colors << (color_array.size == 0 ? random_color : color_array.pop)
	end
	
	pie.colours = colors
	pie.values = values
	
	chart = OpenFlashChart.new
	chart.bg_colour = '#FFFFFF'
	chart.title = title
	chart.add_element(pie)

	chart.x_axis = nil

	return chart.to_json
  end
  
  def majors_graph(discipline_categories)
	sorted_discipline_categories = (discipline_categories.sort_by{ |key, value| value[0] } ).reverse
	
	title = Title.new("Student Discipline Categories")
	bar = BarGlass.new
	
	chart = OpenFlashChart.new
	
	values = []
	labels = []
	y_max = 0
	(1..10).each do |i|
		unless sorted_discipline_categories[i-1].nil? || sorted_discipline_categories[i-1][0].nil?
			values << BarGlassValue.new(sorted_discipline_categories[i-1][1][0])
			labels << sorted_discipline_categories[i-1][0].name
			y_max = sorted_discipline_categories[i-1][1][0] if y_max < sorted_discipline_categories[i-1][1][0]
		end
	end
		
	bar.set_values(values)
	
	x = XAxis.new
	x.set_labels(labels, 10)
	x.colour = "#909090"
	x.grid_colour = '#9ABADB'
	chart.x_axis = x
	
	y = YAxis.new
	y.grid_colour = '#9ABADB'
	y.colour = "#909090"
	
	if y_max > 20
		y.set_range(0, y_max, ((y_max+(100-y_max%100))/20))
	else
		y.set_range(0, y_max, 1)
	end
	chart.y_axis = y
	
	chart.bg_colour = '#FFFFFF'
	chart.set_title(title)
	chart.add_element(bar)
	return chart.to_json
  end
  
  def random_color
		val_array = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E"]
		color = "#"
		6.times do |x|
			color = color + val_array[rand(15)]
		end
		return color
	end
	
	def get_colors
		return ["#BD4F19", "#DBCEAC", "#93B1CC", "#165788", "#898F4B", "#C79900", "#39275B"]
	end

end
























