class CreateArticles < ActiveRecord::Migration[5.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.string :web_url
      t.string :image

      t.timestamps
    end
  end
end
