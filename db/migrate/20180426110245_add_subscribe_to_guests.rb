class AddSubscribeToGuests < ActiveRecord::Migration[5.0]
  def change
    add_column :guests, :subscribe, :boolean, default: false
  end
end
