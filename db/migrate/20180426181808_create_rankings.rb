class CreateRankings < ActiveRecord::Migration[5.0]
  def change
    create_table :rankings do |t|
      t.string :rank
      t.string :team
      t.string :point

      t.timestamps
    end
  end
end
