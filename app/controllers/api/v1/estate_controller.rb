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

		ids = params[:estata_ids]

		# ids = "1991, 1992"
		ids_array = ids.split(",").map { |s| s.to_i }
		items = Realestate.where(:id => ids_array)

		render :json => items

	end

	def get_estate_details

		id = params[:estata_id]

		# id = 1991
		land_data = LandData.where("realestate_id = #{id}")
		building_data = BuildingData.where("realestate_id = #{id}")
		parking_data = ParkingData.where("realestate_id = #{id}")

		detail_data = Array.new
		detail_data << land_data
		detail_data << building_data
		detail_data << parking_data

		render :json => detail_data

	end

	# for house price

	def get_estate_by_distance

		#  1 degree is about 111000m = 111km
		#  1 km = 0.009009009 degree ~= 0.009009 degree
		km_dis = params[:km_dis].to_d
		center_x = params[:center_x].to_f
    	center_y = params[:center_y].to_f
		degree_dis = km_dis * 0.009009 

		critera = "x_long IS NOT NULL and y_lat IS NOT NULL"
		border = "and x_long > #{center_x - degree_dis} and x_long < #{center_x + degree_dis} and y_lat > #{center_y - degree_dis} and y_lat < #{center_y + degree_dis}" 

		items = Realestate.select("id, exchange_year, exchange_month, total_price, square_price, x_long, y_lat, building_type_id, ground_type_id").where("#{critera} #{border}")

		render :json => items
		
	end

end
