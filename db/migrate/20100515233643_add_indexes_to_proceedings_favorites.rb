class AddIndexesToProceedingsFavorites < ActiveRecord::Migration
  def self.up
    add_index :proceedings_favorites, :user_id
    add_index :proceedings_favorites, :session_id
  end

  def self.down
    remove_index :proceedings_favorites, :session_id
    remove_index :proceedings_favorites, :user_id
  end
end
