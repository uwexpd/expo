class CreateOmsfaStudentInfo < ActiveRecord::Migration
  def self.up
    create_table :omsfa_student_info do |t|
      t.integer :person_id
      t.string :alt_email
      t.string :current_address
      t.string :current_city
      t.string :current_state
      t.string :current_zip
      t.string :current_phone
      t.string :permanent_address
      t.string :permanent_city
      t.string :permanent_state
      t.string :permanent_zip
      t.string :parent_firstname
      t.string :parent_lastname
      t.string :parent_email
      t.string :parent2_firstname
      t.string :parent2_lastname
      t.string :parent2_email

      t.timestamps
    end
  end

  def self.down
    drop_table :omsfa_student_info
  end
end
