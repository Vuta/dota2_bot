class AddGuestIdToMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :guest_id, :integer
  end
end
