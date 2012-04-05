class AddPipelinePositionFavorites < ActiveRecord::Migration
  def self.up
    create_table :pipeline_positions_favorites do |t|
      t.integer :person_id
      t.integer :pipeline_position_id
    end
  end

  def self.down
    drop_table :pipeline_positions_favorites
  end
end
