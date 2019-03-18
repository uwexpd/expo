class AddPictureToServiceLearningPosition < ActiveRecord::Migration
  def self.up
    add_column :service_learning_positions, :picture, :string
  end

  def self.down
    remove_column :service_learning_positions, :picture
  end
end
