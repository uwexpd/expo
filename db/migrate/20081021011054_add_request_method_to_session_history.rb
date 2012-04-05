class AddRequestMethodToSessionHistory < ActiveRecord::Migration
  def self.up
    add_column :session_histories, :request_method, :string
  end

  def self.down
    remove_column :session_histories, :request_method
  end
end
