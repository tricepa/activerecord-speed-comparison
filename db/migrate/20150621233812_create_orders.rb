class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.references :client, index: true, foreign_key: true
      t.references :vendor, index: true, foreign_key: true
      t.text :summary

      t.timestamps null: false
    end
  end
end
