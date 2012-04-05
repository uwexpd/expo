class AddAlternateTitleToCommitteeQuarter < ActiveRecord::Migration
  def self.up
    add_column :committee_quarters, :alternate_title, :string
  end

  def self.down
    remove_column :committee_quarters, :alternate_title
  end
end
