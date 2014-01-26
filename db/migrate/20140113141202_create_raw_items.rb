class CreateRawItems < ActiveRecord::Migration
  def change
    create_table :raw_items do |t|
      t.integer :raw_page_id
      t.text :raw_detail
      t.text :raw_xy
      t.integer :item_num

      t.timestamps
    end
    
  end
end
