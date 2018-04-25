class CreateMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :messages do |t|
      t.string :kind
      t.text :content
      t.text :template
      t.string :follow_up_message
      t.text :quick_replies, array: true, default: []

      t.timestamps
    end
  end
end
