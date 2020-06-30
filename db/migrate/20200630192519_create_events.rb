class CreateEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.references :repository, null: false, foreign_key: true
      t.string :payload
      t.string :kind

      t.timestamps
    end
  end
end
