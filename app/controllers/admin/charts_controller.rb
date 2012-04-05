class Admin::ChartsController < Admin::BaseController
	
	def index
		@offering_graph_object = open_flash_chart_object_and_div_name( '100%', '100%', "/admin/charts/offering_line_graph_applicants?o=7")
	end
	
	def offering_line_graph_applicants
		color_array = get_colors
		offerings = Offering.find params[:o].split
		
		graph_title = nil
		
		if offerings.size == 1
			graph_title = Title.new("Applications by Day")
			graph_title.set_style('{font-size: 16px; color: #0077BB}' )
		else
			graph_title = Title.new("Compare Offering Applicants")
		end
		
		lines = []
		y_max = 0
		count_max = 0
		offerings.each do |offering|
			line = LineDot.new
			line.text = offering.name
			applied_days = ApplicationForOffering.find_by_sql "SELECT 
									DATE(created_at) AS date, COUNT(DATE(created_at)) AS total 
									FROM application_for_offerings WHERE offering_id ='#{offering.id}' 
									GROUP BY DATE(created_at) ORDER BY DATE(created_at)"
			start_date = offering.open_date.to_date
			end_date = offering.deadline.to_date
			current_date = start_date
			data = []
			total = 0
			count = 0
			while !applied_days.first.nil? && applied_days.first.date.nil?
				applied_days.shift
			end
			color = color_array.size == 0 ? random_color : color_array.pop
			while !applied_days.first.nil? && applied_days.first.date.to_date < (end_date + 1.week)
				if applied_days.first.date.to_date < start_date
					total += applied_days[0].total.to_i
					applied_days.shift
				elsif applied_days.first.date.to_date > current_date
					tmp = DotValue.new(total)
					tmp.set_tooltip("#{offering.name} <br>Date #{current_date} <br>New 0<br>Total #{total}")
					data << tmp
					current_date += 1.day
					count += 1
				else
					total += applied_days.first.total.to_i
					tmp = DotValue.new(total)
					tmp.set_tooltip("#{offering.name} <br>Date #{current_date} <br>New #{applied_days.first.total}<br>Total #{total}")
					data << tmp
					applied_days.shift
					current_date += 1.day
					count += 1
				end
				while !applied_days.first.nil? && applied_days.first.date.nil?
				applied_days.shift
				end
			end
			data = data.flatten
			
			line.width = 3
			line.colour = color
			line.dot_style = DotStyle.new(color, 4)
			line.values = data
			
			count_max = count if count > count_max
			y_max = total if total > y_max
			lines << line
		end
		
		y = YAxis.new
		if y_max > 20
			y.set_range(0, y_max, ((y_max+(100-y_max%100))/20))
		else
			y.set_range(0, y_max, 1)
		end
		
		y.grid_colour = '#9ABADB'
		y.colour = "#909090"

		x = XAxis.new
		
		x_legend = XLegend.new("Days Since Open Date")
		x_legend.set_style('{font-size: 14px; color: #0077BB}')
		
		x.set_steps( 5 )
		x.colour = "#909090"
		x.grid_colour = '#9ABADB'
		
		y_legend = YLegend.new("Total Applicants")
		y_legend.set_style('{font-size: 14px; color: #0077BB}')

		chart =OpenFlashChart.new
		chart.colour = '#E3F0FD'
		chart.bg_colour = '#FFFFFF'
		chart.set_title(graph_title)
		chart.set_x_legend(x_legend)
		chart.set_y_legend(y_legend)
		
		chart.y_axis = y
		chart.x_axis = x
		
		chart.elements = lines
		
		render :text => chart.to_s
	end
	
	def offering_pie_graph_standings
		color_array = get_colors
		
		offering = Offering.find params[:o]
		
		title = Title.new("Total applications by (current) class standing")

		pie = Pie.new
		pie.start_angle = 35
		pie.animate = true
		pie.tooltip = '#val# of #total#<br>#percent# of 100%'

		standings = {}
		offering.applications_with_status(:in_progress).each do |a|
			standing = a.person.class_standing_description.nil? ? "Unknown" : a.person.class_standing_description(:recent_graduate_placeholder=>"Graduated")
			standings[standing].nil? ? standings=standings.merge({standing=>1}) : standings[standing]+=1
			a.group_members.each do |g|
				unless g.person.nil?
					standing = g.person.class_standing_description.nil? ? "Unknown" : g.person.class_standing_description(:recent_graduate_placeholder=>"Graduated")
				else
					standing = "Unknown"
				end
				standings[standing].nil? ? standings=standings.merge({standing=>1}) : standings[standing]+=1
			end
		end
		
		colors = []
		values = []
		standings.each do |name, value|
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

		render :text => chart.to_s
	end
	
	def offering_bar_graph_statuses
		title = Title.new("Application Statuses")
		bar = BarGlass.new
		
		chart = OpenFlashChart.new
		
		offering = Offering.find params[:o]

		statuses = {}

		offering.statuses.sort.reverse.each do |status|
			count = offering.application_for_offerings.with_status(status.application_status_name).size
			statuses = statuses.merge( { status.application_status_name => count } ) unless count.zero?
		end
		
		values = []
		labels = []
		y_max = 0
		statuses.each do |name, value|
			url = url_for :controller => "apply", :action => offering.id, :id => "list", :anchor => "#{name}" #!!!!# Find out how to do this right #!!!!#
			values << BarGlassValue.new(value,{"on_click" => url})
			labels << name.titleize
			y_max = value if y_max < value
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
		render :text => chart.to_s
	end
	
	def offering_hbar_sessions
		#title = Title.new("Offering Session Times")
	
		hbar = HBar.new
		# could also do it one at a time with hbar.append_value(...) or
		# hbar.values << ...
		time_values = []
		y_labels = []
		full_titles = []
		session_sizes = []
		session_ids = []
		offering = Offering.find params[:o]
		min_start_hour = nil
		max_end_hour = 0.0
		count = 0
		offering.sessions.each do |session|
			start_hour = session.start_time.hour + (session.start_time.min.to_f / 60)
			end_hour = session.end_time.hour + (session.end_time.min.to_f / 60)
			time_values << start_hour.to_s+" "+end_hour.to_s
			if session.title.size > 33
				y_labels << session.title[0..30]+"..."
			else
				y_labels << session.title
			end
			full_titles << session.title
			session_sizes <<  session.presenters.size
			session_ids << session.id
			min_start_hour = start_hour if min_start_hour.nil? || min_start_hour > start_hour
			max_end_hour = end_hour if max_end_hour < end_hour
		end
		
		hbar_values = []
		count = 0
		time_values.reverse.each do |time_value|
			times = time_value.split
			tmp = HBarValue.new( ( times[0].to_f - min_start_hour ), ( times[1].to_f - min_start_hour ))
			tmp.set_tooltip("#{full_titles.reverse[count]}<br>Total Presenters: #{session_sizes.reverse[count]}")
			hbar_values << tmp
			count += 1
		end

		chart = OpenFlashChart.new
		
		
		x_labels = []
		x_label = ""
		minutes = ":00"
		if min_start_hour % 1 > 0
				minutes = ":"+((min_start_hour % 1)*60).to_i.to_s
		end
		while min_start_hour <= (max_end_hour+0.5)
			if min_start_hour >= 13
				x_label = (min_start_hour-12).to_i.to_s+minutes+" pm"
			elsif min_start_hour >= 12
				x_label = min_start_hour.to_i.to_s+minutes+" pm"
			else
				x_label = min_start_hour.to_i.to_s+minutes+" am"
			end
			x_labels << x_label
			min_start_hour += 1.0
		end
		
		hbar.values = hbar_values
		
		chart.bg_colour = '#FFFFFF'
		#chart.set_title(title)s
		chart.add_element(hbar)
		chart.tooltip = Tooltip.new( {"mouse"=>2} )
		
		x = XAxis.new
		x.colour = "#909090"
		x.grid_colour = '#9ABADB'
		x.set_offset(false)
		x.set_labels(x_labels)
		chart.set_x_axis(x)

		y = YAxis.new
		y.grid_colour = '#9ABADB'
		y.colour = "#909090"
		y.set_offset(true)
		y.set_labels(y_labels)
		chart.set_y_axis(y)

		render :text => chart.to_s
	end
	
	def offering_bar_graph_awarded
		requested = params[:r].nil? ? false : true
		offering = Offering.find params[:o]
		applications = offering.application_for_offerings
		# get only awarded ones
		unless requested
			applications.reject! {|a| !a.awarded? }
		end
		
		award_values = {}
		applications.each do |application|
				application.awards.each do |award|
					unless requested
						unless award.amount_approved.nil? || award.disbersement_quarter_id.nil? || award.amount_approved == 0.0
							quarter = Quarter.find award.disbersement_quarter_id
							award_quarter_amounts = award_values[quarter].nil? ? {} : award_values[quarter]
							award_quarter_amounts[award.amount_approved].nil? ? award_quarter_amounts = award_quarter_amounts.merge({award.amount_approved=>1}) : award_quarter_amounts[award.amount_approved]+=1
							if award_values[quarter]
								award_values[quarter] = award_quarter_amounts
							else
								award_values = award_values.merge({quarter => award_quarter_amounts})
							end
						end
					else
						unless award.amount_requested.nil? || award.requested_quarter_id.nil? || award.amount_requested == 0.0
							quarter = Quarter.find award.requested_quarter_id
							award_quarter_amounts = award_values[quarter].nil? ? {} : award_values[quarter]
							award_quarter_amounts[award.amount_requested].nil? ? award_quarter_amounts = award_quarter_amounts.merge({award.amount_requested=>1}) : award_quarter_amounts[award.amount_requested]+=1
							if award_values[quarter]
								award_values[quarter] = award_quarter_amounts
							else
								award_values = award_values.merge({quarter => award_quarter_amounts})
							end
						end
					end
				end
		end
		
		y_max = 0
		values_store = []
		keys = []
		labels = []
		colors = get_colors
		colors_to_use = {}
		award_values.sort.each do |quarter, values|
			labels << quarter.title
			
			bar_values = []
			color = nil
			values.each do |amount, value|
				if colors_to_use[amount].nil?
					color = colors.size == 0 ? random_color : colors.pop
					colors_to_use = colors_to_use.merge( { amount => color } )
					keys << { "colour" => color, "text" => amount.to_s , "font-size"=> 12} 
				else
					color = colors_to_use[amount]
				end
				
				y_max = value if y_max < value
				
				bar_value = nil
				unless requested
					bar_value = { "val"=>value, "colour"=>color, "tip"=>"#{quarter.title}<br>Number Awarded: #{value}<br>Award Amount: #{amount.to_s}" }
				else
					bar_value = { "val"=>value, "colour"=>color, "tip"=>"#{quarter.title}<br>Number Requested: #{value}<br>Requested Amount: #{amount.to_s}" }
				end
				bar_values << bar_value
			end
			
			values_store << bar_values
			
		end
		
		bar = BarStack.new("values"=>values_store, "keys"=>keys)
		
		chart = OpenFlashChart.new
		
		title = nil
		unless requested
			title = Title.new("Award Amounts by Quarter")
		else
			title = Title.new("Requested Amounts by Quarter")
		end
		
		x = XAxis.new
		x.set_labels(labels)
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
		render :text => chart.to_s
	end
	
	def appointment_line_graph
		# The fake appointments go until this date
		today = Date.today
		
		color_array = get_colors
		
		programs = params[:p].split
		class_standings = params[:c].split
		genders = params[:g].split
		time_range = params[:t].to_i
		majors = params[:m].split
		
		graph_title = nil
		
		appointments = nil
		if time_range == 1
			appointments = Appointment.find(:all, :order=>'start_time', :conditions=>{:start_time=>((today-1.year)...(today+1.day))}) 
		else
			appointments = Appointment.find(:all, :order=>'start_time', :conditions=>{:start_time=>((today-(time_range).day)...(today+1.day))}) 
		end
		
		
		lines = []
		y_max = 0
		count_max = 0
		x_max = nil
		programs.each do |program|
			line_text = ''
			program_appointments = []
			if program.to_i != 0
				unit = Unit.find program.to_i
				line_text += unit.name+" "
				
				# Pull out the appropriate appointments
				appointments.each do |appointment|
					program_appointments << appointment if appointment.unit_id == program.to_i
				end
			else
				line_text += "All Programs "
				
				# just give it all the appointments
				program_appointments = appointments
			end
			
			start_value = nil
			# set start_value to have an hour if we are only showing one day
			# set it to the day if we are showing more than one day
			if time_range == 0
				start_value = appointments[0].start_time.to_date+8.hour
			else
				start_value = appointments[0].start_time.to_date+0.hour
			end
			
			# loop once for each class standing, gender, and major once it is added
			# class_standings.each do |class_standing|
			# genders.each do |gender|
			# majors.each do |major|
			data = []
			total = 0
			count = 0
			inner_start_value = start_value
			color = color_array.size == 0 ? random_color : color_array.pop
			
			line = LineDot.new
			line.text = line_text
			
			program_appointments.each do |appointment|
				add_value = true
				if appointment.start_time < (inner_start_value+59.minute)
					
					total += 1
					add_value = false
				end
				while appointment.start_time > (inner_start_value+59.minute)
					tmp = DotValue.new(total)
					tmp.set_tooltip("#{line_text} <br>Time #{inner_start_value.to_s(:time12)} <br>Total #{total}")
					
					inner_start_value += 1.hour
					data << tmp
				end
				if add_value
					total += 1
					tmp = DotValue.new(total)
					tmp.set_tooltip("#{line_text} <br>Time #{inner_start_value.to_s(:time12)} <br>Total #{total}")
				end
			end
			
			tmp = DotValue.new(total)
			tmp.set_tooltip("#{line_text} <br>Time #{inner_start_value.to_s(:time12)} <br>Total #{total}")
			data << tmp
			
			line.width = 3
			line.colour = color
			line.dot_style = DotStyle.new(color, 4)
			line.values = data
			
			y_max = total if total > y_max
			x_max = inner_start_value if x_max == nil || inner_start_value > x_max	
			lines << line
			
			#end
			#end
			#end
			
		end
		
		y = YAxis.new
		if y_max > 20
			y.set_range(0, y_max, ((y_max+(100-y_max%100))/20))
		else
			y.set_range(0, y_max, 1)
		end
		
		y.grid_colour = '#9ABADB'
		y.colour = "#909090"

		x = XAxis.new
		
		x_legend = XLegend.new("Date / Time")
		x_legend.set_style('{font-size: 14px; color: #0077BB}')
		
		x.colour = "#909090"
		x.grid_colour = '#9ABADB'
		
		y_legend = YLegend.new("Appointments")
		y_legend.set_style('{font-size: 14px; color: #0077BB}')

		chart =OpenFlashChart.new
		chart.colour = '#E3F0FD'
		chart.bg_colour = '#FFFFFF'
		chart.set_title(graph_title) if graph_title
		chart.set_x_legend(x_legend)
		chart.set_y_legend(y_legend)
		
		chart.y_axis = y
		chart.x_axis = x
		
		chart.elements = lines
		
		render :text => chart.to_s
	end
	
	def appointment_graph
		
		results = appointment_program_bar_graph( params )
		unless results.nil?
			stats = results[1]
			percent_feilds = {}
			project_percents = stats[1]
			standing_percents = stats[2]
			gender_percents = stats[3]
			
			percent_feilds = percent_feilds.merge({"p"=>project_percents, "c"=>standing_percents, "g"=>gender_percents})
			render :text => percent_feilds.to_json+"|SPLIT|"+results[0].to_s
		else
			render :text => '{ "elements": [ { "type": "bar", "values": [0,0,0,0,0,0,0]}],"title": { "text": "No Appointments To Display", "style": "{font-size: 12px; color: #999;}" },"y_axis":{"colour":"#909090","min":0,"grid-colour":"#D0E0EF"},"x_axis":{"colour":"#909090","grid-colour":"#D0E0EF"},"bg_colour":"#FFFFFF"}'
		end
	end
	
	def appointment_program_bar_graph( params )
		# Todays date, change to test
		today = Date.today #"2009-09-25".to_date #
		
		colors = get_colors # holds the colors to use first
		colors_to_use = {} # holds the colors for the stack bar
		
		#programs = params[:p].split
		#class_standings = params[:c].split
		#genders = params[:g].split
		time_range = params[:t].nil? ? 0 : params[:t].to_i
		#majors = params[:m].split
		
		title = case time_range
						when 0 then Title.new("Appointments: Today")
						when 7 then Title.new("Appointments: Past Week")
						when 30 then Title.new("Appointments: Past Thirty Days")
						when 100 then Title.new("Appointments: Past 100 Days")
						else Title.new("Appointments: Past Year")
					end
		title = nil
		
		# Find the right range of appointments 
		appointments = nil
		if time_range == 1
			appointments = Appointment.find(:all, :order => 'start_time', :conditions => {:start_time => ((today-1.year)...(today+1.day))}) 
		elsif time_range == 0
			appointments = Appointment.find(:all, :order => 'start_time', :conditions => {:start_time => ((today-(time_range).day)...(today+1.day))}) 
		else
			appointments = Appointment.find(:all, :order => 'start_time', :conditions => {:start_time => ((today-(time_range-1).day)...(today+1.day))}) 
		end
		
		if appointments.size == 0 || appointments.nil?
			return nil
		end
		
		y_max = 0
		
		start_value = nil
		# set start_value to have an hour if we are only showing one day
		# set it to the day if we are showing more than one day
		if time_range == 0
			start_value = appointments[0].start_time.to_date+8.hour
		else
			start_value = appointments[0].start_time.to_date+0.hour
		end
		
		values = [[],[]] # values[0] is the value for each program / values[1] is the total
		counts = [[],[], [], []] # counts[0] is the count for the current interval | count[1] is the running totals for each program | counts[2] is for the class standings | counts[3] is for genders
		total_color = colors.pop
		colors_to_use = colors_to_use.merge( { 0 => total_color } )
		keys = [[],[]]
		keys[1] << { "colour" => total_color, "text" => "All Programs" , "font-size"=> 9} 
		
		# how much the x should change
		interval = case time_range
						when 0 then 1
						when 7 then 1.day
						when 30 then 1.day
						when 100 then 5.day
						else 7.day
					end
		range_to_look = case time_range # makes sure it looks at appointments between larger intervals
						when 100 then 4.day
						when 1 then 6.day
						else 0
					end
		
		inner_start_value = start_value
		inner_start_value_used = (time_range == 0) ? inner_start_value.hour : inner_start_value.to_date
		
		appointments.each do |appointment|
		
			# depending on the time range figure out values to use
			appointment_start_time = (time_range == 0) ? appointment.start_time.hour : appointment.start_time.to_date
			
			while appointment_start_time > (inner_start_value_used+range_to_look)
				# returned = [bar_values, colors, colors_to_use, y_max, keys, counts]
				returned = add_bar_stacks(time_range, inner_start_value, inner_start_value_used, counts, colors_to_use, y_max, keys, colors, interval)
				if counts[0].size == 0
					# add in a blank value to make a space
					color = colors_to_use[0]
					returned[0][0] << { "val" => 0, "colour" => color }
					returned[0][1] << { "val" => 0, "colour" => color }
				end
				values[0] << returned[0][0]
				values[1] << returned[0][1]
				colors= returned[1]
				colors_to_use = returned[2]
				y_max = returned[3]
				keys = returned[4]
				
				inner_start_value_used += interval
				counts[0] = []
			end
			
			####!!!! Collect Stats here !!!!####
			# Program stats --- Interval Totals and Running Totals
			counts[1][0].nil? ? (counts[1][0] = 1) : (counts[1][0] += 1) # running total
			counts[0][0].nil? ? (counts[0][0] = 1) : (counts[0][0] += 1) # current interval total
			counts[1][appointment.unit_id].nil? ? (counts[1][appointment.unit_id] = 1) : (counts[1][appointment.unit_id] += 1) # running total for the program
			counts[0][appointment.unit_id].nil? ? (counts[0][appointment.unit_id] = 1) : (counts[0][appointment.unit_id] += 1) # current interval total for the program
			
			unless appointment.student.nil?
				# Standing stats --- Running Totals
				class_standing_id = appointment.student.class_standing_id
				unless class_standing_id.nil? || class_standing_id == 0
					counts[2][class_standing_id].nil? ? counts[2][class_standing_id] = 1 : counts[2][class_standing_id] += 1
				end
				counts[2][0].nil? ? counts[2][0] = 1 : counts[2][0] += 1
				
				# Gender stats --- Running Totals
				counts[3][0].nil? ? counts[3][0] = 1 : counts[3][0] += 1
				unless appointment.student.gender.nil?
					if appointment.student.gender.strip.downcase == "f"
						counts[3][1].nil? ? counts[3][1] = 1 : counts[3][1] += 1
					else
						counts[3][2].nil? ? counts[3][2] = 1 : counts[3][2] += 1
					end
				end
			end
			
		end
		if counts[0].size > 0
			returned = add_bar_stacks(time_range, inner_start_value, inner_start_value_used, counts, colors_to_use, y_max, keys, colors, interval)
			values[0] << returned[0][0]
			values[1] << returned[0][1]
			colors= returned[1]
			colors_to_use = returned[2]
			y_max = returned[3]
			keys = returned[4]
		
		end
		
		# Bluild the x_labels
		stop_x_value = (time_range == 0) ? (inner_start_value+(17-inner_start_value.hour)) : (inner_start_value_used+1.day)
		start_x_value = start_value
		count = 0
		x_labels = []
		while start_x_value <= stop_x_value
			label = (time_range == 0) ? (start_x_value+count.hour).to_s(:time12) : start_x_value.to_date
			x_labels << label
			start_x_value += interval
			count += 1
		end
		
		bar = BarStack.new("values"=>values[0], "keys"=>keys[0])
		
		while inner_start_value_used <= (inner_start_value.hour + 8)
			color = colors_to_use[0]
			values[1] << { "val" => 0, "colour" => color, "tip" => "All Programs 0" }
			inner_start_value_used += 1
		end
		total_bar = BarStack.new("values"=>values[1], "keys"=>keys[1])
		
		
		chart = OpenFlashChart.new
		
		x = XAxis.new
		# Set the rotaion depending on the time_range
		if time_range == 1
			x.set_labels(x_labels, 60)
		elsif time_range <= 7
			x.set_labels(x_labels)
		elsif time_range <= 100 
			x.set_labels(x_labels, 30)
		end
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
		chart.tooltip = Tooltip.new( {"mouse"=>2} )
		chart.bg_colour = '#FFFFFF'
		chart.set_title(title) if title
		chart.add_element(total_bar)
		chart.add_element(bar)
		
		return [chart, counts]
	end
	
	# This builds the stack sections for the appointment_program_bar_graph chart
	def add_bar_stacks(time_range, inner_start_value, inner_start_value_used, counts, colors_to_use, y_max, keys, colors, interval)
		bar_values = [[],[]] # bar_values[0] is the value for each program / bar_values[1] is the total
		tool_tip = (time_range == 0) ? "<br>Time: #{(inner_start_value+(inner_start_value_used-inner_start_value.hour).hour).to_s(:time12)}" : "<br>Date range: #{inner_start_value_used} | #{inner_start_value_used+interval}"
		tmp = 0
		counts[0].each do |count|
			if tmp == 0
				color = colors_to_use[tmp]
				bar_values[1] << { "val" => count, "colour" => color, "tip" => "All Programs "+tool_tip+"<br>This Interval: #{count}<br>Running Total: #{counts[1][tmp]}" }
				y_max = count if count > y_max
			elsif count != nil
				color = nil
				if colors_to_use[tmp].nil?
					color = colors.size == 0 ? random_color : colors.pop
					colors_to_use = colors_to_use.merge( { tmp => color } )
					keys[0] << { "colour" => color, "text" => Unit.find(tmp).name , "font-size"=> 9} 
				else
					color = colors_to_use[tmp]
				end
				bar_values[0] << { "val" => count, "colour" => color, "tip" => "#{Unit.find(tmp).name} "+tool_tip+"<br>This Interval: #{count} (~ #{  (count.to_f / counts[0][0]*100).to_i unless counts[0][0].nil? || counts[0][0] == 0 }% )<br>Running Total: #{counts[1][tmp]} (~ #{  (counts[1][tmp].to_f / counts[1][0]*100).to_i unless counts[1][0].nil? || counts[1][0] == 0  }% )" }
			end
			tmp += 1
		end
		return [bar_values, colors, colors_to_use, y_max, keys]
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