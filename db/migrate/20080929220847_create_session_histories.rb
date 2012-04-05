class CreateSessionHistories < ActiveRecord::Migration
  def self.up
    create_table :session_histories do |t|
      t.string :session_id
      t.string :request_uri

      t.timestamps
    end
  end

  def self.down
    drop_table :session_histories
  end
end
