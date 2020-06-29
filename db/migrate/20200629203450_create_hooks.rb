class CreateHooks < ActiveRecord::Migration[6.0]
  def change
    create_table :hooks do |t|
      t.string :hook_type
      t.string :name
      t.boolean :active
      t.string :url
      t.integer :external_id

      t.timestamps
    end
  end
end
