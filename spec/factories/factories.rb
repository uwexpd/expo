# This will create a Person
Factory.define :person do |p|
	p.firstname 'Philip'
	p.lastname 'Fry'
	p.email 'expohelp@u.wahington.edu'
	p.salutation  'Mr.'
	p.address1 'Planet Express Building'
	p.city 'New New York'
	p.state 'New York'
	p.zip '10293'
end

# This will create a Student
Factory.define :student do |s|
	s.firstname 'Philip'
	s.lastname 'Fry'
	s.email 'expohelp@u.wahington.edu'
	s.salutation 'Mr.'
	s.address1 'Planet Express Building'
	s.city 'New New York'
	s.state 'New York'
	s.zip '10293'
end

# Create a User
Factory.define :simple_user, :class => User do |u|
	u.email 'expohelp@u.wahington.edu'
	u.login { Factory.next(:login) }
	u.password 'secret' 
	u.password_confirmation 'secret' 
end

# Create a User with a person attached
Factory.define :user, :parent => :simple_user do |u|
	u.association :person, :factory => :person
end

# Make sure all logins are unique 
Factory.sequence :login do |n|
	"tester#{n}"
end

# Create a Mentor
Factory.define :mentor, :class => ApplicationMentor do |m|
	m.association :person, :factory => :person
end

# Create a Quarter #### Can only use quarter code factory 4 times Expo assumes there are only 4
Factory.define :quarter do |q|
	q.year 2000
	q.first_day "2000-01-01"
	q.association :quarter_code, :factory => :quarter_code
end

# Create a Quarter Code #### Can only use quarter code factory 4 times Expo assumes there are only 4
Factory.define :quarter_code do |q|
	q.sequence(:id) {|n| (1+n) }
	q.name "Test"
	q.abbreviation "T"
end

# Create an Event
Factory.define :event do |e|
	e.title "Test Event"
	e.description "A test event"
	e.association :unit, :factory => :unit
	e.association :offering, :factory => :offering
end

# Create a Uint
Factory.define :unit do |e|
	e.name "Test Unit"
	e.abbreviation "TU"
end
