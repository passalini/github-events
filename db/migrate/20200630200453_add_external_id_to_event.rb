class AddExternalIdToEvent < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :external_id, :integer
    add_column :events, :type, :string
  end
end
