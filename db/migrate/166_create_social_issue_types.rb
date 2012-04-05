class CreateSocialIssueTypes < ActiveRecord::Migration
  def self.up
    create_table :social_issue_types do |t|
      t.string :title
      t.integer :parent_social_issue_type_id

      t.timestamps
      t.userstamps
    end
  end

  def self.down
    drop_table :social_issue_types
  end
end
