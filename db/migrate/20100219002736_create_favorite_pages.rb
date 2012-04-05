class CreateFavoritePages < ActiveRecord::Migration
  def self.up
    create_table :favorite_pages do |t|
      t.integer :user_id
      t.string :url
      t.string :title
      t.integer :position
      t.timestamps
    end
  end

  def self.down
    drop_table :favorite_pages
  end
end
