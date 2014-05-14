# encoding: utf-8
class GetEstateWorker
  include Sidekiq::Worker
  sidekiq_options queue: "estate"
  
  def perform(crawl_month)
    
    url = "http://1.34.193.26/api/v2/estate/get_month_data?exchange_month="
	# exchange_month = 10101
	exchange_month = crawl_month
	url = url + exchange_month.to_s
	response = Typhoeus.get(url)

	datas = JSON.parse(response.body)
	datas.each do |data|

		puts data["address"]

		estate = Realestate.new
		estate.estate_group = data["estate_group"]
		estate.address = data["address"]
		estate.exchange_year = data["exchange_year"]
		estate.exchange_month = data["exchange_month"]
		estate.total_price = data["total_price"]
		
		begin
			estate.square_price = data["square_price"].to_d
		rescue Exception => e
			
		end
		
		begin
			estate.total_area = data["total_area"].to_d
		rescue Exception => e
			
		end
		
		estate.exchange_content = data["exchange_content"]
		estate.building_type = data["building_type"]
		estate.building_rooms = data["building_rooms"]

		begin
			estate.x_long = data["x_long"].to_d
		rescue Exception => e
			
		end
		
		begin
			estate.y_lat = data["y_lat"].to_d
		rescue Exception => e
			
		end		
		estate.item_num = data["item_num"]
		estate.is_detail_crawled = data["is_detail_crawled"]
		estate.county_id = data["county_id"]
		estate.town_id = data["town_id"]
		estate.ground_type_id = data["ground_type_id"]
		estate.building_type_id = data["building_type_id"]
		estate.notes = data["notes"]
		estate.exchange_date = data["exchange_date"]
		estate.is_show = data["is_show"]
		estate.save

	end

  end

end