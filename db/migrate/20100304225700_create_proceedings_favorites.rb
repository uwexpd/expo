class CreateProceedingsFavorites < ActiveRecord::Migration
  def self.up
    create_table :proceedings_favorites do |t|
      t.integer :user_id
      t.integer :application_for_offering_id

      t.timestamps
    end
  end

  def self.down
    drop_table :proceedings_favorites
  end
end
