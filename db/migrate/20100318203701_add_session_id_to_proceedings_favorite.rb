class AddSessionIdToProceedingsFavorite < ActiveRecord::Migration
  def self.up
    add_column :proceedings_favorites, :session_id, :string
  end

  def self.down
    remove_column :proceedings_favorites, :session_id
  end
end
