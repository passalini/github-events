class AddUserToHook < ActiveRecord::Migration[6.0]
  def change
    add_reference :hooks, :user, null: false, foreign_key: true
  end
end
