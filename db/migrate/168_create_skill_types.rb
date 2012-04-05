class CreateSkillTypes < ActiveRecord::Migration
  def self.up
    create_table :skill_types do |t|
      t.string :title

      t.timestamps
      t.userstamps
    end
  end

  def self.down
    drop_table :skill_types
  end
end
