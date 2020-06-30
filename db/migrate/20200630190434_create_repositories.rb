class CreateRepositories < ActiveRecord::Migration[6.0]
  def change
    create_table :repositories do |t|
      t.integer :external_id
      t.string :full_name
      t.text :description
      t.string :html_url

      t.timestamps
    end
  end
end
