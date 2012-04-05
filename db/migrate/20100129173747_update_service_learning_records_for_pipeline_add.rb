class UpdateServiceLearningRecordsForPipelineAdd < ActiveRecord::Migration
  def self.up
    # update Organization Quarters to include units
    # this migration assumes that all of the organization quarters should be linked to the Carlson Center
    unit = Unit.find_by_abbreviation "carlson"
    OrganizationQuarter.all.each do |oq|
      oq.update_attribute(:unit_id,unit.id)
    end
    
    unit_id_s = unit.id.to_s
    # links contacts that have the does service learning tag to the carlson center
    OrganizationContact.all.each do |oc|
      if oc.primary_service_learning_contact
        oc.update_attribute(:contact_units,{:unit_ids=>[unit_id_s],:primary_contact=>[unit_id_s]})
      end
    end
  end

  def self.down
    
  end
end
