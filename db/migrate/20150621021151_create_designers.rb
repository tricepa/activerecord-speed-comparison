class CreateDesigners < ActiveRecord::Migration
  def change
    create_table :designers do |t|
      t.string :name
      t.string :email
      t.string :level

      t.timestamps null: false
    end
  end
end
