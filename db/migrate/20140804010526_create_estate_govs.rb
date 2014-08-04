class CreateEstateGovs < ActiveRecord::Migration
  def change
    create_table :estate_govs do |t|
      t.string :county
      t.string :ground_type
      t.string :address
      t.decimal :ground_area, :precision => 10, :scale => 2
      t.string :land_usage

      t.integer :exchange_date
      t.string :exchange_content
      t.string :layer
      t.string :total_layer
      t.string :building_type
      t.string :building_purpose
      t.string :building_material
      t.string :building_date
      t.string :building_area

      t.string :building_rooms
      t.integer :total_price
      t.decimal :square_price, :precision => 10, :scale => 2
      
      t.string :parking_type
      t.decimal :parking_area_total, :precision => 10, :scale => 2
      t.integer :parking_price

      t.decimal :x_long,  :precision => 15, :scale => 10
      t.decimal :y_lat, :precision => 15, :scale => 10

      t.timestamps
    end
  end
end
