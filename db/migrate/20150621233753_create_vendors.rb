class CreateVendors < ActiveRecord::Migration
  def change
    create_table :vendors do |t|
      t.string :name
      t.boolean :promotion

      t.timestamps null: false
    end
  end
end
