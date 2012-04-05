class AddProceedingsPdfFileFieldsToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :proceedings_pdf_letterhead, :string
  end

  def self.down
    remove_column :offerings, :proceedings_pdf_letterhead
  end
end
