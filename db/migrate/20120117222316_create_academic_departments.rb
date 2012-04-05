class CreateAcademicDepartments < ActiveRecord::Migration
  def self.up
    create_table :academic_departments do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :academic_departments
  end
end
