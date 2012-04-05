class AddHowDidYouHearToApplicationForOffering < ActiveRecord::Migration
  def self.up
    add_column :application_for_offerings, :how_did_you_hear, :text
  end

  def self.down
    remove_column :application_for_offerings, :how_did_you_hear
  end
end
