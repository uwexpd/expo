class MakeChangesToOfferingQuestionsAndOfferingPages < ActiveRecord::Migration
  def self.up
    # offering_pages
    add_column :offering_pages, :introduction, :text
    
    # offering_questions
    add_column :offering_questions, :type, :string
    add_column :offering_questions, :required_now, :boolean
    add_column :offering_questions, :help_text, :text
    add_column :offering_questions, :character_limit, :integer
    add_column :offering_questions, :word_limit, :integer
    
    # offering_question_types
    drop_table :offering_question_types
    
    # offering_question_validations
    create_table :offering_question_validations do |t|
      t.integer "offering_question_id"
      t.string "type"
      t.string "parameter"
    end
    
    # offerings
    add_column :offerings, :contact_name, :string
    add_column :offerings, :contact_email, :string
    add_column :offerings, :contact_phone, :string
    
  end

  def self.down
    remove_column :offering_pages, :introduction
    remove_column :offering_questions, :type
    
    create_table "offering_question_types", :force => true do |t|
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    drop_table :offering_question_validations
    remove_column :offering_questions, :required_now
    remove_column :offering_questions, :help_text
    remove_column :offering_questions, :character_limit
    remove_column :offering_questions, :word_limit
    remove_column :offerings, :contact_name
    remove_column :offerings, :contact_email
    remove_column :offerings, :contact_phone
  end
end
