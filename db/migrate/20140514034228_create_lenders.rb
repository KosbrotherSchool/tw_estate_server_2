class CreateLenders < ActiveRecord::Migration
  def change
    create_table :lenders do |t|
      t.string :name
      t.string :sexual
      t.string :loacation
      t.string :phone
      t.string :phone_time

      t.timestamps
    end
  end
end
