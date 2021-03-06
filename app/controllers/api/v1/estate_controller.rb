class Api::V1::EstateController < ApplicationController

	def around_all_by_areas

		center_x = 121.7155930000
		center_y = 25.1215410000
		delta_x = 0.00772495
		delta_y = 0.01102129

		# center_x = params[:center_x].to_f
    	# center_y = params[:center_y].to_f
    	# delta_x = params[:delta_x].to_f
    	# delta_y = params[:delta_y].to_f


    	critera = "x_long IS NOT NULL and y_lat IS NOT NULL"
    	border = "and x_long > #{center_x - delta_x} and x_long < #{center_x + delta_x} and y_lat > #{center_y - delta_y} and y_lat < #{center_y + delta_y}" 

    	items = Realestate.where("#{critera} #{border}").paginate(:page => 1, :per_page => 10)

    	render :json => items
	end

	#### zillion use the following three method

	def get_around_estates

		# center_x = 121.7155930000
		# center_y = 25.1215410000
		# delta_x = 0.00772495
		# delta_y = 0.01102129

		center_x = params[:center_x].to_f
    	center_y = params[:center_y].to_f
    	delta_x = params[:delta_x].to_f
    	delta_y = params[:delta_y].to_f


    	critera = "x_long IS NOT NULL and y_lat IS NOT NULL"
    	border = "and x_long > #{center_x - delta_x} and x_long < #{center_x + delta_x} and y_lat > #{center_y - delta_y} and y_lat < #{center_y + delta_y}" 

    	items = Realestate.select("id, estate_group, x_long, y_lat").where("#{critera} #{border}").paginate(:page => 1, :per_page => 10)

    	render :json => items

	end

	def get_estates_by_ids

		ids = params[:estate_ids]

		# ids = "1991, 1992"
		ids_array = ids.split(",").map { |s| s.to_i }
		items = Realestate.where(:id => ids_array)

		render :json => items

	end

	def get_estate_details

		id = params[:estate_id]

		# id = 1991
		estate = Realestate.find(id)
		land_data = LandData.where("realestate_id = #{id}")
		building_data = BuildingData.where("realestate_id = #{id}")
		parking_data = ParkingData.where("realestate_id = #{id}")

		detail_data = Array.new
		detail_data << estate
		detail_data << land_data
		detail_data << building_data
		detail_data << parking_data

		render :json => detail_data

	end

	# for house price

	def get_estate_by_distance

		# 25.05535, 121.4588 

		#  1 degree is about 111000m = 111km
		#  1 km = 0.009009009 degree ~= 0.009009 degree
		km_dis = params[:km_dis].to_d
		center_x = params[:center_x].to_f
    	center_y = params[:center_y].to_f
		degree_dis = km_dis * 0.009009 

		house_price_min = params[:hp_min]
		house_price_max = params[:hp_max]

		area_min = params[:a_min]
		area_max = params[:a_max]

		ground_type = params[:ground_type]
		building_type = params[:building_type]

		# square_price_min = params[:sp_min]
		# square_price_max = params[:sp_max]

		housePrice = ""
		if house_price_min != nil
			housePrice = "and total_price >= #{house_price_min} "
		end

		if house_price_max != nil
			housePrice = housePrice + "and total_price < #{house_price_max} "
		end

		areaString = ""
		if area_min != nil
			areaString = "and total_area >= #{area_min} "
		end

		if area_max != nil
			areaString = areaString + "and total_area < #{area_max}"
		end

		crawlDate = CrawlRecord.last
		crawlMonth = crawlDate.crawl_month
		crawlYear = crawlDate.crawl_year
		beginMonth = 0
		beginYear = 0
		if (crawlMonth > 4)
			beginMonth = crawlMonth - 3
			beginYear = crawlYear
		else
			beginMonth = crawlMonth + 13 - 4
			beginYear = crawlYear - 1
		end

		groundType = ""
		if ground_type != nil
			if ground_type.index("0")
				# do nothing
			else
				if ground_type.index("1")
					if groundType.length == 0
						groundType = groundType + " and ( ground_type_id = 1"
					else
						groundType = groundType + " or ground_type_id = 1"
					end
				end

				if ground_type.index("2")
					if groundType.length == 0
						groundType = groundType + " and ( ground_type_id = 2"
					else
						groundType = groundType + " or ground_type_id = 2"
					end
				end

				if ground_type.index("3")
					if groundType.length == 0
						groundType = groundType + " and ( ground_type_id = 3"
					else
						groundType = groundType + " or ground_type_id = 3"
					end
				end

				if ground_type.index("4")
					if groundType.length == 0
						groundType = groundType + " and ( ground_type_id = 4"
					else
						groundType = groundType + " or ground_type_id = 4"
					end
				end

				if ground_type.index("5")
					if groundType.length == 0
						groundType = groundType + " and ( ground_type_id = 5"
					else
						groundType = groundType + " or ground_type_id = 5"
					end
				end

				groundType = groundType + ")"
			end
		end

		buildingType = ""
		if building_type != nil

			if building_type.index("a")
				if buildingType.length == 0
					buildingType = buildingType + " and ( building_type_id = 1"
				else
					buildingType = buildingType + " or building_type_id = 1"
				end
			end

			if building_type.index("b")
				if buildingType.length == 0
					buildingType = buildingType + " and ( building_type_id = 2"
				else
					buildingType = buildingType + " or building_type_id = 2"
				end
			end

			if building_type.index("c")
				if buildingType.length == 0
					buildingType = buildingType + " and ( building_type_id = 3"
				else
					buildingType = buildingType + " or building_type_id = 3"
				end
			end

			if building_type.index("d")
				if buildingType.length == 0
					buildingType = buildingType + " and ( building_type_id = 4"
				else
					buildingType = buildingType + " or building_type_id = 4"
				end
			end

			if building_type.index("e")
				if buildingType.length == 0
					buildingType = buildingType + " and ( building_type_id = 5"
				else
					buildingType = buildingType + " or building_type_id = 5"
				end
			end

			if building_type.index("f")
				if buildingType.length == 0
					buildingType = buildingType + " and ( building_type_id = 6"
				else
					buildingType = buildingType + " or building_type_id = 6"
				end
			end

			if building_type.index("g")
				if buildingType.length == 0
					buildingType = buildingType + " and ( building_type_id = 7"
				else
					buildingType = buildingType + " or building_type_id = 7"
				end
			end

			if building_type.index("h")
				if buildingType.length == 0
					buildingType = buildingType + " and ( building_type_id = 8"
				else
					buildingType = buildingType + " or building_type_id = 8"
				end
			end

			if building_type.index("i")
				if buildingType.length == 0
					buildingType = buildingType + " and ( building_type_id = 9"
				else
					buildingType = buildingType + " or building_type_id = 9"
				end
			end

			if building_type.index("j")
				if buildingType.length == 0
					buildingType = buildingType + " and ( building_type_id = 10"
				else
					buildingType = buildingType + " or building_type_id = 10"
				end
			end

			if building_type.index("k")
				if buildingType.length == 0
					buildingType = buildingType + " and ( building_type_id = 11"
				else
					buildingType = buildingType + " or building_type_id = 11"
				end
			end

			if building_type.index("l")
				if buildingType.length == 0
					buildingType = buildingType + " and ( building_type_id = 12"
				else
					buildingType = buildingType + " or building_type_id = 12"
				end
			end

			buildingType = buildingType + ")"
		end

		timeRange = ""
		if beginYear == crawlYear
			timeRange = "and exchange_year=#{beginYear} and exchange_month <= #{crawlMonth} and exchange_month >= #{beginMonth}"
		else
			timeRange = "and ( exchange_year = #{crawlYear} OR (exchange_year=#{beginYear} and exchange_month >= #{beginMonth}) )"
		end

		critera = "x_long IS NOT NULL and y_lat IS NOT NULL and is_show = true"
		border = "and x_long > #{center_x - degree_dis} and x_long < #{center_x + degree_dis} and y_lat > #{center_y - degree_dis} and y_lat < #{center_y + degree_dis}" 

		items = Realestate.select("id, exchange_year, exchange_month, total_price, square_price, total_area, x_long, y_lat, building_type_id, ground_type_id").where("#{critera} #{border} #{timeRange} #{groundType} #{buildingType} #{housePrice} #{areaString}")

		render :json => items
		
	end

	def get_current_crawl_data
		crawlDate = CrawlRecord.select("id, crawl_year, crawl_month").last
		render :json => crawlDate
	end


end
