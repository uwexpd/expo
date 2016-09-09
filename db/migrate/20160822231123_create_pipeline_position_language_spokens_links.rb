class CreatePipelinePositionLanguageSpokensLinks < ActiveRecord::Migration
  def self.up
    create_table :pipeline_positions_language_spokens_links do |t|
      t.integer :pipeline_position_id
      t.integer :pipeline_positions_language_spoken_id

      t.timestamps
    end
  end

  def self.down
    drop_table :pipeline_positions_language_spokens_links
  end
end
