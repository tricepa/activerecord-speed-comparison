class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.references :designer, index: true, foreign_key: true
      t.boolean :active
      t.string :name
      t.string :email

      t.timestamps null: false
    end
  end
end
