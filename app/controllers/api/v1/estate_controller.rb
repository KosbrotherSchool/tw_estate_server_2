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


end
