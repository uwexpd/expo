class CreateGeneralStudyFaculties < ActiveRecord::Migration
  def self.up
    create_table :general_study_faculties do |t|
      t.string :firstname
      t.string :lastname
      t.string :uw_netid   
      t.string :code
      t.string :employee_id
      t.string :person_id

      t.timestamps
    end
  end

  def self.down
    drop_table :general_study_faculties
  end
end
