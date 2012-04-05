class CreateApplicationModeratorDecisionTypes < ActiveRecord::Migration
  def self.up
    create_table :application_moderator_decision_types do |t|
      t.string :title
      t.boolean :yes_option
      t.integer :offering_id

      t.timestamps
    end
  end

  def self.down
    drop_table :application_moderator_decision_types
  end
end
