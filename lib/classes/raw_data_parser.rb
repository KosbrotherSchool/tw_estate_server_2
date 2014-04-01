# encoding: utf-8
class RawDataParser

	require "nokogiri"
	require "rubygems"

	def parse_raw_data raw_page_id

		puts "I am in "

		# parse raw_page
		raw_page = RawPage.find(raw_page_id)
		page_num = raw_page.page_num

		page_no = Nokogiri::HTML(raw_page.html)

		1.upto 200 do |item_num| 

			item_num = item_num + page_num - 200

			puts "item num: " + item_num.to_s

			item = page_no.css("##{item_num}")

			theRealEstate = Realestate.new
			theRealEstate.is_show = false

			if item.size == 0
				puts "break"
				break
			end
			
			if item.size > 1
				item = item[0]
			end

			address = ""
	 		begin
	 			theRealEstate.address = item.children[0].children[2].to_s.strip
	 		rescue Exception => e
	 			
	 		end		 		
	 		# exchange_date
	 		exchange_date = ""
	 		begin
	 			exchange_date = item.children[2].children.to_s.strip
	 			divide_position = exchange_date.index("/")
	 			theRealEstate.exchange_year = exchange_date[0..divide_position-1].to_i
	 			theRealEstate.exchange_month = exchange_date[divide_position+1..exchange_date.length].to_i
	 			theRealEstate.exchange_date = theRealEstate.exchange_year  * 100 + theRealEstate.exchange_month
	 		rescue Exception => e
	 			
	 		end	
	 		# total_price
	 		total_price = ""
	 		begin
	 			total_price = item.children[4].children[1].children.to_s.strip
	 			theRealEstate.total_price = total_price.gsub(",","").to_i
	 		rescue Exception => e
	 			
	 		end	
	 		
	 		# square_price
	 		square_price = ""
	 		begin
	 			square_price = item.children[6].children[1].children.to_s.strip
	 			theRealEstate.square_price = square_price.gsub(",","").to_d
	 		rescue Exception => e
	 			
	 		end	
	 		
	 		# total_area
	 		total_area = ""
	 		begin
	 			total_area = item.children[8].children.to_s.strip
	 			theRealEstate.total_area = total_area.gsub(",","").to_d
	 		rescue Exception => e
	 			
	 		end	
	 		
	 		# exchange content
	 		# exchange_content = ""
	 		begin
	 			theRealEstate.exchange_content = item.children[10].children.to_s.strip
	 		rescue Exception => e
	 			
	 		end	
	 		
	 		# building_type
	 		building_type = ""
	 		begin
	 			building_type = item.children[12].children[1][:title]
	 			theRealEstate.building_type = building_type
	 			if building_type.index("公寓")
	 				theRealEstate.building_type_id = 1
	 			elsif building_type.index("透天厝")
	 				theRealEstate.building_type_id = 2
	 			elsif building_type.index("店面")
	 				theRealEstate.building_type_id = 3
	 			elsif building_type.index("辦公商業大樓")
	 				theRealEstate.building_type_id = 4
	 			elsif building_type.index("住宅大樓")
	 				theRealEstate.building_type_id = 5
	 			elsif building_type.index("華廈")
	 				theRealEstate.building_type_id = 6
	 			elsif building_type.index("套房")
	 				theRealEstate.building_type_id = 7
	 			elsif building_type.index("工廠")
	 				theRealEstate.building_type_id = 8
	 			elsif building_type.index("廠辦")
	 				theRealEstate.building_type_id = 9
	 			elsif building_type.index("農舍")
	 				theRealEstate.building_type_id = 10
	 			elsif building_type.index("倉庫")
	 				theRealEstate.building_type_id = 11
	 			elsif building_type.index("其他")
	 				theRealEstate.building_type_id = 12
	 			end
	 		rescue Exception => e
	 			
	 		end	

	 		# building_rooms
	 		# building_rooms = ""
	 		begin
	 			theRealEstate.building_rooms = item.children[14].children.to_s.strip
	 		rescue Exception => e
	 			
	 		end	
	 		

	 		theRealEstate.town_id = raw_page.town_id
	 		theRealEstate.county_id = raw_page.county_id

	 		## judge the ground type id
	 		item_view = page_no.css("#full_view#{item_num}")
	 		ground_type = item_view.css("tr")[2].children[2].children.to_s
	 		if ground_type == "房地(土地+建物)"
	 			theRealEstate.ground_type_id = 1
	 		elsif ground_type == "房地(土地+建物)+車位"
	 			theRealEstate.ground_type_id = 2
	 		elsif ground_type == "土地"
	 			theRealEstate.ground_type_id = 3
	 		elsif ground_type == "建物"
	 			theRealEstate.ground_type_id = 4
	 		elsif ground_type == "車位"
	 			theRealEstate.ground_type_id = 5
	 		end

	 		noteString = item_view.css("tr td a")[1].children[0]["onkeypress"]

	 		noteString = noteString[noteString.index("detail(")..noteString.length]

	 		notes = ""

	 		begin
	 			notes = noteString[noteString.index("'")+1..noteString.index("')")-1 ]
	 		rescue Exception => e
	 			
	 		end
	 		

	 		theRealEstate.notes = notes

	 		theRealEstate.item_num = item_num

	 		# set only crawl realestate now
	 		theRealEstate.estate_group = 1
	 		theRealEstate.save

			# use raw_page id to parse other datas
			raw_item = RawItem.where(" raw_page_id = #{raw_page.id} And item_num = #{item_num} ").first

			if raw_item == nil
				break
			end

			# parse detail
			page_no_detail = Nokogiri::HTML(raw_item.raw_detail)

			landtable = page_no_detail.css("table#land_data")
			land_data_size = 0

			# puts "item num: " + item_num.to_s + " land size " + land_data_size.to_s

			begin
				land_data_size = landtable.css("tr").size
				2.upto(land_data_size) do |x|
					item = landtable.css("tr")[x-1]
					newLandData = LandData.new
					newLandData.land_position =  item.children[0].children.to_s.strip
					newLandData.land_area = item.children[2].children.to_s.strip
					newLandData.land_usage = item.children[4].children.to_s.strip
					newLandData.realestate_id = theRealEstate.id
					newLandData.save
					theRealEstate.is_detail_crawled = true
				end
			rescue Exception => e
				
			end

			

			buildingTable_size = 0
			begin
				buildingTable = page_no_detail.css("#houselist .popup_box")
				buildingTable_size = buildingTable.css("tr").size
				2.upto(buildingTable_size) do |x|
					item = buildingTable.css("tr")[x-1]
					newBuildingData = BuildingData.new
					newBuildingData.building_age = item.children[0].children.to_s.strip.to_i
					newBuildingData.building_area = item.children[2].children.to_s.strip
					newBuildingData.building_purpose = item.children[4].children.to_s.strip
					newBuildingData.building_material = item.children[6].children.to_s.strip
					newBuildingData.building_built_date = item.children[8].children.to_s.strip
					newBuildingData.building_total_layer = item.children[10].children.to_s.strip
					newBuildingData.building_layer =  item.children[12].children.to_s.strip
					newBuildingData.realestate_id = theRealEstate.id
					newBuildingData.save
				end
			rescue Exception => e
				
			end

			# begin
			# 	list_note = page_no_detail.css("#list_note")
			# 	theRealEstate.notes = list_note.children.to_s.strip
			# 	# theRealEstate.save
			# rescue Exception => e

			# end

			park_data_size = 0
			begin
				parktable = page_no_detail.css("#parklist .popup_box")
				park_data_size = parktable.css("tr").size
				2.upto(park_data_size) do |x|
					item = parktable.css("tr")[x-1]
					newParkingData = ParkingData.new
					newParkingData.index = item.children[0].children.to_s.strip
					newParkingData.parking_type = item.children[2].children.to_s.strip
					newParkingData.parking_price = item.children[4].children.to_s.strip
					newParkingData.parking_area = item.children[6].children.to_s.strip
					newParkingData.realestate_id = theRealEstate.id
					newParkingData.save
				end
			rescue Exception => e
				
			end

			puts "land size: " + land_data_size.to_s + " building size: " + buildingTable_size.to_s + " parking size: " + park_data_size.to_s

			# parse x, y
			xy_body = raw_item.raw_xy
			xy_body = xy_body.gsub(" ","")
			xy_body = xy_body.gsub("\n","")
			xy_body = xy_body.gsub("\r","")

			x_long = xy_body[0..xy_body.index("&")-1]
			xy_body = xy_body[xy_body.index("&")+1..xy_body.length]
			y_lat = xy_body[0..xy_body.index("&")-1]

			theRealEstate.x_long = x_long
			theRealEstate.y_lat = y_lat
			theRealEstate.save

		end

		raw_page.is_parsed = true
		raw_page.save

	end

end