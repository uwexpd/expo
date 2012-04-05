module UserSpecHelper
	def valid_person_attributes
		{
			:firstname => 'Philip',
			:lastname => 'Fry',
			:email => 'expohelp@u.wahington.edu',
			:salutation => 'Mr.',
			:address1 => 'Planet Express Building',
			:city => 'New New York',
			:state => 'New York',
			:zip => '10293',
			:require_validations => true
		}
	end
	def valid_user_attributes
		{ 
			:email => 'expohelp@u.wahington.edu',
			:login => 'tester',
			:password => 'secret' ,
			:password_confirmation => 'secret' 
		}
	end
	def valid_user_attributes_with_person
		{ 
		:email => 'expohelp@u.wahington.edu',
		:login => 'tester',
		:password => 'secret' ,
		:password_confirmation => 'secret' ,
		:person_attributes => 
			{
			:firstname => 'Philip',
			:lastname => 'Fry',
			:email => 'expohelp@u.wahington.edu',
			:salutation => 'Mr.',
			:address1 => 'Planet Express Building',
			:city => 'New New York',
			:state => 'New York',
			:zip => '10293',
			:require_validations => true
			}
		}
	end
end