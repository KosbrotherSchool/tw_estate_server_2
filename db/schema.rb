# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140113141202) do

  create_table "building_data", force: true do |t|
    t.integer  "building_age"
    t.string   "building_area"
    t.string   "building_purpose"
    t.string   "building_material"
    t.string   "building_built_date"
    t.string   "building_total_layer"
    t.string   "building_layer"
    t.integer  "realestate_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "building_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "counties", force: true do |t|
    t.string   "name"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ground_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "land_data", force: true do |t|
    t.string   "land_position"
    t.string   "land_area"
    t.string   "land_usage"
    t.integer  "realestate_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "parking_data", force: true do |t|
    t.string   "index"
    t.string   "parking_type"
    t.string   "parking_price"
    t.string   "parking_area"
    t.integer  "realestate_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "raw_items", force: true do |t|
    t.integer  "raw_page_id"
    t.text     "raw_detail"
    t.string   "raw_xy"
    t.integer  "item_num"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "raw_pages", force: true do |t|
    t.text     "html",       limit: 2147483647
    t.integer  "page_num"
    t.integer  "county_id"
    t.integer  "town_id"
    t.boolean  "is_parsed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "realestates", force: true do |t|
    t.integer  "estate_group"
    t.string   "address"
    t.integer  "exchange_year"
    t.integer  "exchange_month"
    t.integer  "total_price"
    t.decimal  "square_price",      precision: 10, scale: 2
    t.decimal  "total_area",        precision: 10, scale: 2
    t.string   "exchange_content"
    t.string   "building_type"
    t.string   "building_rooms"
    t.decimal  "x_long",            precision: 15, scale: 10
    t.decimal  "y_lat",             precision: 15, scale: 10
    t.integer  "item_num"
    t.boolean  "is_detail_crawled"
    t.integer  "county_id"
    t.integer  "town_id"
    t.integer  "ground_type_id"
    t.integer  "building_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "notes"
  end

  create_table "towns", force: true do |t|
    t.string   "name"
    t.string   "code"
    t.integer  "county_id"
    t.integer  "current_rows_num"
    t.boolean  "is_crawl_finished"
    t.datetime "last_crawl_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
