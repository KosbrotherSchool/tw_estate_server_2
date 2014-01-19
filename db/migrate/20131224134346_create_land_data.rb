class CreateLandData < ActiveRecord::Migration
  def change
    create_table :land_data do |t|
      t.string :land_position
      t.string :land_area
      t.string :land_usage

      t.integer :realestate_id
      t.timestamps
    end
  end
end
