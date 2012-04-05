class AddResultVariantToPopulations < ActiveRecord::Migration
  def self.up
    add_column :populations, :result_variant, :string
    add_column :populations, :custom_result_variant, :text
  end

  def self.down
    remove_column :populations, :custom_result_variant
    remove_column :populations, :result_variant
  end
end
