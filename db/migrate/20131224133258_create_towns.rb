class CreateTowns < ActiveRecord::Migration
  def change
    create_table :towns do |t|
      t.string :name
      t.string :code
      t.integer :county_id

      t.integer :current_rows_num
      t.boolean :is_crawl_finished
      t.datetime :last_crawl_date
      t.timestamps
    end
  end
end
