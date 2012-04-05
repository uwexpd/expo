class CreateClassStandings < ActiveRecord::Migration
  def self.up
    create_table :class_standings do |t|
      t.string :abbreviation
      t.string :description
      t.timestamps
    end
    
    say_with_time "Populating class_standings with values from Data Warehouse..." do
      ClassStanding.create :id => 1, :abbreviation => "FRESH", :description => "Freshman"
      ClassStanding.create :id => 2, :abbreviation => "SOPH", :description => "Sophomore"
      ClassStanding.create :id => 3, :abbreviation => "JUNIOR", :description => "Junior"
      ClassStanding.create :id => 4, :abbreviation => "SENIOR", :description => "Senior"
      ClassStanding.create :id => 5, :abbreviation => "5TH YR", :description => "Fifth Year"
      ClassStanding.create :id => 6, :abbreviation => "N-MATR", :description => "Non-Matriculated"
      ClassStanding.create :id => 7, :abbreviation => "RECENT", :description => "Recent Graduate"
      ClassStanding.create :id => 8, :abbreviation => "GRAD", :description => "Graduate"
      ClassStanding.create :id => 9, :abbreviation => "", :description => ""
      ClassStanding.create :id => 10, :abbreviation => "", :description => ""
      ClassStanding.create :id => 11, :abbreviation => "PROF-1", :description => "1st Year Prof"
      ClassStanding.create :id => 12, :abbreviation => "PROF-2", :description => "2nd Year Prof"
      ClassStanding.create :id => 13, :abbreviation => "PROF-3", :description => "3rd Year Prof"
      ClassStanding.create :id => 14, :abbreviation => "PROF-4", :description => "4th Year Prof"    
    end
  end

  def self.down
    drop_table :class_standings
  end
end
