class CreateBuildingData < ActiveRecord::Migration
  def change
    create_table :building_data do |t|
      t.integer :building_age
      t.string :building_area
      t.string :building_purpose
      t.string :building_material
      t.string :building_built_date
      t.string :building_total_layer
      t.string :building_layer

      t.integer :realestate_id
      t.timestamps
    end
  end
end
