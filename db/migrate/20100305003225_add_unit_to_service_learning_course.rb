class AddUnitToServiceLearningCourse < ActiveRecord::Migration
    def self.up
      add_column :service_learning_courses, :unit_id, :integer

      # fill in the added unit attribute
      unit = Unit.find_by_abbreviation "carlson"
      ServiceLearningCourse.all.each do |slc|
        slc.update_attribute(:unit_id,unit.id)
      end
    end

    def self.down
      remove_column :service_learning_courses, :unit_id
    end
  end
