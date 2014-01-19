class CreateRawPages < ActiveRecord::Migration
  def change
    create_table :raw_pages do |t|
      t.text :html, :limit => 4294967295
      t.integer :page_num
      t.integer :county_id
      t.integer :town_id
      t.boolean :is_parsed

      t.timestamps
    end
  end
end
