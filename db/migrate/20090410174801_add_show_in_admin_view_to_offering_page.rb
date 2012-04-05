class AddShowInAdminViewToOfferingPage < ActiveRecord::Migration
  def self.up
    add_column :offering_pages, :hide_in_admin_view, :boolean
  end

  def self.down
    remove_column :offering_pages, :hide_in_admin_view
  end
end
