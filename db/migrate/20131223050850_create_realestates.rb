class CreateRealestates < ActiveRecord::Migration
  def change
    create_table :realestates do |t|
      # group 1 for real_estate, 2 for pre_sale, 3 for rent
      t.integer :estate_group
      t.string :address
      t.integer :exchange_year
      t.integer :exchange_month
      t.integer :total_price
      t.decimal :square_price, :precision => 10, :scale => 2
      t.decimal :total_area, :precision => 10, :scale => 2
      t.string	:exchange_content
      t.string  :building_type
      t.string  :building_rooms

      t.decimal :x_long,  :precision => 15, :scale => 10
      t.decimal :y_lat, :precision => 15, :scale => 10

      t.integer :item_num
      t.boolean :is_detail_crawled

      t.integer :county_id
      t.integer :town_id
      t.integer :ground_type_id
      t.integer :building_type_id
      t.timestamps
    end
  end
end
