class AddImageUrlToRankings < ActiveRecord::Migration[5.0]
  def change
    add_column :rankings, :image_url, :string
  end
end
