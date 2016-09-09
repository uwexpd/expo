class CreatePipelinePositionLanguageSpokens < ActiveRecord::Migration
  def self.up
    create_table :pipeline_positions_language_spokens do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :pipeline_positions_language_spokens
  end
end
