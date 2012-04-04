class PubcookieUser < User

  #validate :person_is_valid
  def allow_invalid_person?
    true
  end
  
  # For use in polymporphic finds. TODO: This is a hack.
  def self.parent_class
    User
  end

=begin
  def person_is_valid
    true  
  end
=end
  

=begin rdoc
Authenticates a user by their login name without a password.  Returns the user if found.  If we don't find a user record, we create one.In some cases, a single UWNetID needs to have multiple associated user accounts. For example, if a staff member is an alumnus (and therefore has a student record as well) or a graduate student serves as a mentor, we need to be able to distinguish between these different "identities" of the same person. Therefore, self#authenticate can be passed +require_identity+, which is an identity type that that user must authenticate as. If +require_identity+ is not passed, the PubcookieUser will _always_ be authenticated as a generic User and will not have access to a student record. If "Student" is passed as the required_identity, the User will be authenticated as a Student if a StudentRecord is found or as a generic Person if a StudentRecord cannot be found. For this reason, it is possible for there to be multiple Users with the same login, as long as the login is unique within the scope of the User's +identity_type+.
=end  
  def self.authenticate(uwnetid, password = nil, require_identity = nil)
    u = self.find_by_identity uwnetid, require_identity
    if u.nil?
      u = PubcookieUser.new :login => uwnetid
      u.identity_type = require_identity
      if require_identity == 'Student'
        u.person = Student.find_by_uw_netid(uwnetid)
        return false if u.person.nil? # If we required a Student and no student record exists, then auth fails.
      else
        u.person = Person.create || Student.find_by_uw_netid(uwnetid)
      end
      u.save
    end
    u
  end
  
  # Construct the user's email address based on the UWNetID.  At the UW, all uwnetid's correspond to an
  # e-mail address @u.washington.edu (Actually, this may or may not be true... some depts have their own email servers - mharris2 4/15/08)
  def email
    login + '@u.washington.edu'
  end
  
  protected
    # Pubcookie users do not store passwords in our DB because weblogin contains all authentication data
    def password_required?
      false
    end

    # Finds a user with the matching identity type
    def self.find_by_identity(uwnetid, identity_type = nil)
      self.find_by_login_and_identity_type(uwnetid, identity_type)
    end
 

  
end
