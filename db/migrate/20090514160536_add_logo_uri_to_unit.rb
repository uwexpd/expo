class AddLogoUriToUnit < ActiveRecord::Migration
  def self.up
    add_column :units, :logo_uri, :string
  end

  def self.down
    remove_column :units, :logo_uri
  end
end
