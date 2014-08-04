
namespace :output do

	task :insert_estage_govs => :environment do

		exchange_date = ENV['DATE']
		puts "date #{exchange_date}"
		exchange_date = exchange_date.to_i

		Realestate.where("exchange_date = #{exchange_date}").each_with_index do |estate, index|
			puts index.to_s

			e_gov = EstateGov.new
			e_gov.county = County.find(estate.county_id).name
			e_gov.town = Town.find(estate.town_id).name
			e_gov.ground_type = GroundType.find(estate.ground_type_id).name
			e_gov.address = estate.address
			
			groundAera = 0
			LandData.where("realestate_id = #{estate.id}").each do |landData|
				begin
					e_gov.land_usage = landData.land_usage
					groundAera = groundAera + landData.land_area.gsub(",","").to_d
				rescue Exception => e
					
				end
			end
			e_gov.ground_area = groundAera

			e_gov.exchange_date = estate.exchange_date
			e_gov.exchange_content = estate.exchange_content

			buildingArea = 0
			buildingDatas = BuildingData.where("realestate_id = #{estate.id}")
			buildingDatas.each_with_index do |buildingData, index|
				begin
					if buildingData.building_layer != nil && buildingData.building_layer != ""
						e_gov.layer = buildingData.building_layer
					end
					buildingArea = buildingArea + buildingData.building_area.gsub(",","").to_d
				rescue Exception => e
					
				end

				if index+1 == buildingDatas.size	
					e_gov.total_layer = buildingData.building_total_layer
					e_gov.building_purpose = buildingData.building_purpose
					e_gov.building_material = buildingData.building_material
					e_gov.building_date = buildingData.building_built_date
				end
			end
			e_gov.building_area = buildingArea

			begin
				e_gov.building_type = BuildingType.find(estate.building_type_id).name
			rescue Exception => e
				e_gov.building_type = ""
			end
			
			e_gov.building_rooms = estate.building_rooms
			e_gov.total_price = estate.total_price
			e_gov.square_price = estate.square_price


			parkingArea = 0
			parkingPrice = 0
			parkingDatas = ParkingData.where("realestate_id = #{estate.id}")
			parkingDatas.each_with_index do |parkingData, index|
				begin
					parkingArea = parkingArea + parkingData.parking_area.gsub(",","").to_d
					parkingPrice = parkingPrice + parkingData.parking_price.gsub(",","").to_i
				rescue Exception => e
					
				end
				if index+1 == parkingDatas.size
					e_gov.parking_type = parkingData.parking_type
				end
			end
			e_gov.parking_area_total = parkingArea
			e_gov.parking_price = parkingPrice

			e_gov.x_long = estate.x_long
			e_gov.y_lat = estate.y_lat
			e_gov.estate_id = estate.id

			e_gov.save
		end

	end

	task :output_json => :environment do

		exchange_date = ENV['DATE']
		puts "date #{exchange_date}"
		exchange_date = exchange_date.to_i
		estate = EstateGov.where("exchange_date = #{exchange_date}")

		Dir.mkdir('public') unless File.exists?('public')
		File.open("public/#{exchange_date}.json","w") do |f|
		 f.write(estate.to_json)
		end

	end

end