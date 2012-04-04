desc "Add people to interview committee"
task :add_to_interviewers => :environment do
  
  users = {
    'mcnaim' => {:firstname => 'Mary', :lastname =>'McNair', :email => 'mcnaim@u.washington.edu'},
    'donnan' => {:firstname => 'Donna', :lastname =>'Neagle', :email => 'donnan@u.washington.edu'},
    'msclaire' => {:firstname => 'Claire', :lastname =>'Fraczek', :email => 'msclaire@u.washington.edu'},
    'jkiest' => {:firstname => 'Jennifer', :lastname =>'Kiest', :email => 'jkiest@u.washington.edu'},
    'ferris3' => {:firstname => 'Sean', :lastname =>'Ferris', :email => 'ferris3@u.washington.edu'},
    'vincentr' => {:firstname => 'Vincent', :lastname =>'Gonzalez', :email => 'vincentr@u.washington.edu'},
    'jdthomas' => {:firstname => 'Jo-Nathan', :lastname =>'Thomas', :email => 'jdthomas@u.washington.edu'},
    'mikese' => {:firstname => 'Maggie', :lastname =>'Fonseca', :email => 'mikese@u.washington.edu'},
    'castick' => {:firstname => 'Christine', :lastname =>'Stickler', :email => 'castick@u.washington.edu'},
    'aespania' => {:firstname => 'Alejandro', :lastname =>'Espania', :email => 'aespania@uw.edu'},
    'nkenney' => {:firstname => 'Nancy', :lastname =>'Kenney', :email => 'nkenney@u.washington.edu'},
    'myersja' => {:firstname => 'Jenee', :lastname =>'Myers', :email => 'myersja@u.washington.edu'},
    'ccamp1' => {:firstname => 'Christopher', :lastname =>'Campbell', :email => 'ccamp1@u.washington.edu'},
    'robinc' => {:firstname => 'Robin', :lastname =>'Chang', :email => 'robinc@u.washington.edu'},
    'carrill0' => {:firstname => 'Daniel', :lastname =>'Carillo', :email => 'carrill0@u.washington.edu'},
    'jdecosmo' => {:firstname => 'Janice', :lastname =>'DeCosmo', :email => 'jdecosmo@u.washington.edu'},
    'carrill0' => {:firstname => 'Daniel', :lastname =>'Carrillo Jr.', :email => 'carrill0@u.washington.edu'},
    'ljwiles' => {:firstname => 'LeAnne', :lastname =>'Wiles', :email => 'ljwiles@uwb.edu'},
    'rbonus' => {:firstname => 'Rick', :lastname =>'Bonus', :email => 'rbonus@u.washington.edu'},
    'ccaci' => {:firstname => 'Cynthia', :lastname =>'Caci', :email => 'ccaci@u.washington.edu'},
    'franlo' => {:firstname => 'Francesca', :lastname =>'Lo', :email => 'franlo@u.washington.edu'},
    'apeloff' => {:firstname => 'Amy', :lastname =>'Peloff', :email => 'apeloff@u.washington.edu'},
    'purschk' => {:firstname => 'Kathryn', :lastname =>'Pursch', :email => 'purschk@u.washington.edu'},
    'mpitre' => {:firstname => 'Mona', :lastname =>'Pitre-Collins', :email => 'mpitre@u.washington.edu'},
    'sugie' => {:firstname => 'Christine', :lastname =>'Sugatan', :email => 'sugie@u.washington.edu'},
    'mattwojo' => {:firstname => 'Matt', :lastname =>'Wojciakowski', :email => 'mattwojo@u.washington.edu'},
    'jgml' => {:firstname => 'Jamie', :lastname =>'Lee', :email => 'jgmlee@gmail.com'},
    'llj' => {:firstname => 'Lincoln', :lastname =>'Johnson', :email => 'llj@u.washington.edu'},
    'mjundt' => {:firstname => 'Michaelann', :lastname =>'Jundt', :email => 'mjundt@u.washington.edu'},
    'rbonus' => {:firstname => 'Rick', :lastname =>'Bonus', :email => 'rbonus@u.washington.edu'},
    'sarahh4' => {:firstname => 'Sarah', :lastname =>'Hamilton', :email => 'sarahh4@u.washington.edu'},
    'jodene' => {:firstname => 'Jodene', :lastname =>'Davis', :email => 'jodene@u.washington.edu'},
    'rvaughn' => {:firstname => 'Rachel', :lastname =>'Vaughn', :email => 'rvaughn@u.washington.edu'},
    'kmihata' => {:firstname => 'Kevin', :lastname =>'Mihata', :email => 'kmihata@u.washington.edu'},
    'rubyroxy' => {:firstname => 'Ruby', :lastname =>'Linsao', :email => 'rubyroxy@u.washington.edu'},
    'ebedgar' => {:firstname => 'Eugene', :lastname =>'Edgar', :email => 'ebedgar@u.washington.edu'},
    'apapini' => {:firstname => 'Anthony', :lastname =>'Papini', :email => 'anthony@pridefoundation.org'},
    'llj' => {:firstname => 'Lincoln', :lastname =>'Johnson', :email => 'llj@uw.edu'},
    'ljwiles' => {:firstname => 'LeAnne', :lastname =>'Wiles', :email => 'ljwiles@uw.edu'},
    'myersja' => {:firstname => 'Jenee', :lastname =>'Myers Twitchell', :email => 'myersja@uw.edu'},
    'rbonus' => {:firstname => 'Rick', :lastname =>'Bonus', :email => 'rbonus@uw.edu'},
    'nahe' => {:firstname => 'Susan', :lastname =>'Terry', :email => 'nahe@uw.edu'},
    'ccaci' => {:firstname => 'Cynthia', :lastname =>'Caci', :email => 'ccaci@uw.edu'},       
  }
  
  users.each do |username, person_attributes|
    user = PubcookieUser.authenticate(username)
    if user.person.nil?
      user.person.create(person_attributes)
    elsif user.person.firstname.blank?
      user.person.update_attributes(person_attributes)
    end
    Offering.find(253).interviewers.create(:person_id => user.person_id)
    puts username
  end
  
  
  
  
  
end