rakeclass CreateCrawlRecords < ActiveRecord::Migration
  def change
    create_table :crawl_records do |t|
      t.integer :crawl_year
      t.integer :crawl_month

      t.timestamps
    end
  end
end
