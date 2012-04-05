class AddThemeResponseWordLimitsToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :theme_response_word_limit, :integer
    add_column :offerings, :theme_response2_word_limit, :integer
  end

  def self.down
    remove_column :offerings, :theme_response2_word_limit
    remove_column :offerings, :theme_response_word_limit
  end
end
