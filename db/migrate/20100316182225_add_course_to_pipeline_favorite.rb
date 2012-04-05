class AddCourseToPipelineFavorite < ActiveRecord::Migration
  def self.up
    add_column :pipeline_positions_favorites, :service_learning_course_id, :integer
  end

  def self.down
    remove_column :pipeline_positions_favorites, :service_learning_course_id
  end
end
