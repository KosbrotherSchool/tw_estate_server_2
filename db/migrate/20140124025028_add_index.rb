class AddIndex < ActiveRecord::Migration
  def change

  	add_index :realestates, :county_id
    add_index :realestates, :town_id
    add_index :realestates, :ground_type_id
    add_index :realestates, :building_type_id  	

  	add_index :raw_pages, :county_id
  	add_index :raw_pages, :town_id
  	
  	add_index :raw_items, :raw_page_id
    add_index :raw_items, :item_num

  	add_index :towns, :county_id

  	add_index :land_data, :realestate_id
  	add_index :building_data, :realestate_id
  	add_index :parking_data, :realestate_id

  end
end
