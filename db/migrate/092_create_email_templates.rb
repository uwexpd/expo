class CreateEmailTemplates < ActiveRecord::Migration
  def self.up
    create_table :email_templates do |t|
      t.text :body
      t.string :name
      t.string :subject
      t.string :from

      t.timestamps
    end
  end

  def self.down
    drop_table :email_templates
  end
end
