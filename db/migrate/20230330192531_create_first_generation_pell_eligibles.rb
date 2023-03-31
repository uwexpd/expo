class CreateFirstGenerationPellEligibles < ActiveRecord::Migration
  def self.up
    create_table :first_generation_pell_eligibles, :primary_key => :system_key do |t|
      # t.integer :system_key
      t.boolean :first_gen
      t.boolean :pell_eligible

      t.timestamps
    end
  end

  def self.down
    drop_table :first_generation_pell_eligibles
  end
end
