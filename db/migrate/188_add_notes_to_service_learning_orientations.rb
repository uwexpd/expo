class AddNotesToServiceLearningOrientations < ActiveRecord::Migration
  def self.up
    add_column :service_learning_orientations, :notes, :text
  end

  def self.down
    remove_column :service_learning_orientations, :notes
  end
end
