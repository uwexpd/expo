# Allows any model to have a randomly generated token which can used for authenticating via things like e-mail links.
class Token < ActiveRecord::Base
  stampable
  belongs_to :tokenable, :polymorphic => true
  after_create :generate
  
  attr_protected :token
  
  def to_s
    token
  end
  
  def generate
    update_attribute(:token, random_string(16))
    token
  end

  # Finds an object from an ID and token, and then re-generates the token.
  def self.find_object(object_id, token, regenerate_when_done = true)
    if t = self.find_by_tokenable_id_and_token(object_id, token)
      logger.info { "Token Success: Object found (object_id: #{object_id}, token: #{token})" }
      t.generate if regenerate_when_done
      return t.tokenable
    else
      logger.info { "Token Failure: Invalid token/ID combination (object_id: #{object_id}, token: #{token})" }
      return nil
    end
  end

  protected
  
  def random_string(len)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    newpass
  end
  
end
