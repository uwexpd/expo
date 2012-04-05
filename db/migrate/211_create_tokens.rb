class CreateTokens < ActiveRecord::Migration
  def self.up
    create_table :tokens do |t|
      t.integer :tokenable_id
      t.string :tokenable_type
      t.string :token

      t.timestamps
    end
  end

  def self.down
    drop_table :tokens
  end
end
