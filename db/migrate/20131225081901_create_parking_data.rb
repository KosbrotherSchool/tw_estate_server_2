class CreateParkingData < ActiveRecord::Migration
  def change
    create_table :parking_data do |t|
      t.string :index
      t.string :parking_type
      t.string :parking_price
      t.string :parking_area

      t.integer :realestate_id
      t.timestamps
    end
  end
end
