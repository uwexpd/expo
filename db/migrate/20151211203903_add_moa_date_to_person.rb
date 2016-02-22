class AddMoaDateToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :service_learning_moa_date, :datetime
  end

  def self.down
    remove_column :people, :service_learning_moa_date
  end
end
