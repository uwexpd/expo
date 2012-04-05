class CreateApplicationOtherAwards < ActiveRecord::Migration
  def self.up
    create_table :application_other_awards do |t|
      t.string :title
      t.boolean :secured
      t.float :amount

      t.timestamps
    end
  end

  def self.down
    drop_table :application_other_awards
  end
end
