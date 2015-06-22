class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.boolean :active
      t.string :name
      t.string :email

      t.timestamps null: false
    end
  end
end
