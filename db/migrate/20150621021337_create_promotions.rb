class CreatePromotions < ActiveRecord::Migration
  def change
    create_table :promotions do |t|
      t.references :vendor, index: true, foreign_key: true
      t.boolean :active
      t.string :summary

      t.timestamps null: false
    end
  end
end
