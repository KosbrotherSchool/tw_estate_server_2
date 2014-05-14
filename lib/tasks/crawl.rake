# encoding: utf-8
require "rubygems"
require "typhoeus"
require "nokogiri"
require "open-uri"
require 'tesseract'
require 'capybara'
require 'capybara/dsl'

namespace :crawl do

	task :crawl_db_data => :environment do

		url = "http://1.34.193.26/api/v2/estate/get_month_data?exchange_month="
		exchange_month = 10101
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

	task :perform_crawl_db_worker => :environment do

		10301.upto 10302 do |num|
			GetEstateWorker.perform_async(num)
		end

	end

	task :crawl_data => :environment do

		url = "http://lvr.land.moi.gov.tw/N11/ImageNumberN13?"

		cookies = nil


		# found towns which is_crawl_finished = false
		mTown = Town.where("is_crawl_finished = false").first
		mCounty = County.find(mTown.county_id)
		Qry_city = mCounty.code
		Qry_area_office = mTown.code

		puts "query city: " + mCounty.name + "query town: " + mTown.name

		downloaded_file = File.open("image#{mTown.id}.jpeg",'wb')
		request = Typhoeus::Request.new(
			url		
		)

		request.on_body do |chunk|
		  downloaded_file.write(chunk)
		end
		request.on_complete do |response|
		  downloaded_file.close
		  # puts response.headers_hash
		  response_header = response.headers_hash
		  cookies = response_header['Set-Cookie']
		  # puts cookies
		end

		request.run

		img = MiniMagick::Image.open("image#{mTown.id}.jpeg")
		img.crop("#{img[:width] - 2}x#{img[:height] - 2}+1+1") #去掉边框（上下左右各1像素）  
		img.colorspace("GRAY") #灰度化  
		img.monochrome #二值化  

		e = Tesseract::Engine.new {|e|
		  e.language  = :eng
		  e.whitelist = '0123456789'
		}

		auto_login_code = e.text_for(img).strip.gsub(" ","")
		auto_login_code = auto_login_code[0..3]
		puts auto_login_code

		login_code = STDIN.gets.chomp
		url = "http://lvr.land.moi.gov.tw/N11/login.action"

		response = Typhoeus.post(
			url,
			params:{ 
				rand_code: login_code,
				command: "login",
				in_type: "land",
				formaturl: "",
			},
			:headers => {
				:cookie => cookies
			}
		)

		# puts response.body

		if response.code != 200
			puts "request denied"
			return
		else
			puts response.code
			puts "scraping " + url
		end


		# change menu
		response_change = Typhoeus.post(
			"http://lvr.land.moi.gov.tw/N11/pro/codeClass.action",
			:headers => {
				:cookie => cookies
			},
			:params => {
				'type' => "BUILDTYPE"
			}
		)

		puts response_change.body

		# dom = Nokogiri::HTML(response.body)
		# puts dom.css("body")

		# Call JavaScript Function
		source = open("http://lvr.land.moi.gov.tw/INC/js/qt_base64.js").read
		context = ExecJS.compile(source)
		# context.call("doBase64","C")
		Qry_city = context.call("doBase64",Qry_city)
		Qry_area_office = context.call("doBase64",Qry_area_office)
		Qry_p_yyy_s = context.call("doBase64","101")
		Qry_p_yyy_e = context.call("doBase64","102")
		Qry_season_s = context.call("doBase64","1")
		Qry_season_e = context.call("doBase64","11")

		# get token
		token = getToken(cookies)	

		# qry_land_url = "http://lvr.land.moi.gov.tw/N11/QryClass_land.action"
		qry_land_url = "http://lvr.land.moi.gov.tw/N11/QryClass_sale.action"


		qry_land_request = Typhoeus::Request.new(
		  	qry_land_url,
		  	method: :post,
		  	:params => { 
		  		'type' => URI::encode("UXJ5ZGF0YQ=="),
		  		'Qry_city' => URI::encode(Qry_city),
		  		'Qry_area_office' => URI::encode(Qry_area_office),
		  		'Qry_paytype' => URI::encode("MSwyLDMsNCw1"),
		  		'Qry_build' => "",
		  		'Qry_price_s' => "",
		  		'Qry_price_e' => "",
		  		'Qry_unit_price_s' => "",
		  		'Qry_unit_price_e' => "",
		  		'Qry_p_yyy_s' => URI::encode(Qry_p_yyy_s),
		  		'Qry_p_yyy_e' => URI::encode(Qry_p_yyy_e),
		  		'Qry_season_s' => URI::encode(Qry_season_s),
		  		'Qry_season_e' => URI::encode(Qry_season_e),
		  		'Qry_doorno' => "",
		  		'Qry_area_s' => "",
		  		'Qry_area_e' => "",
		  		'Qry_order' => URI::encode("UUEwOCZkZXNj"),
		  		'Qry_unit' => URI::encode("Mg=="),
		  		'Qry_area_srh' => "",
		  		'Qry_buildyear_s' => "",
		  		'Qry_buildyear_e' => "",
		  		'Qry_origin' => URI::encode("P"),
		  		'Qry_avg' => URI::encode("off"),
		  		'struts.token.name' => URI::encode("token"),
		  		'token' => URI::encode(token)
		  	},
		  	headers:{
				cookie: cookies
			}
		)

		puts qry_land_request.url

		qry_land_request.run

		qry_land_response = qry_land_request.response

		puts "query land-------------"
		puts qry_land_response.body

		if qry_land_response.code != 200
			puts "request denied"
			return
		else
			puts qry_land_response.code
			puts "request land data: " + qry_land_url
		end


		# get current_rows_num & start with current rows
		current_rows_num = mTown.current_rows_num + 200

		if current_rows_num == 200
			puts "crawl first 200 items"
			page_no = Nokogiri::HTML(qry_land_response.body, nil, "UTF-8")
			if page_no.css("#hiddenresult").size != 0
				html_table = page_no.css("#hiddenresult")
				mTown.current_rows_num = current_rows_num
				mTown.save
			else
				puts "nil html"
				mTown.is_crawl_finished = true
				mTown.save
				return
			end
		else
			# query next 200 page
			sleep(1)
			puts "crawl next 200 items"

			# puts "request http://lvr.land.moi.gov.tw/N11/LandBuildSort"

			next_page_request =  Typhoeus::Request.new(
			  	"http://lvr.land.moi.gov.tw/N11/LandBuildSort",
			  	method: :post,
			  	:params => { 
			  		'order' => URI::encode("QA08"),
			  		'sort' => 1,
			  		'Qry_city' => URI::encode(Qry_city),
			  		'Qry_area_office' => URI::encode(Qry_area_office),
			  		'Qry_unit' => 2,
			  		'rowno' => current_rows_num
			  	},
			  	headers:{
					cookie: cookies
				}
			)

			puts next_page_request.url

			next_page_request.run
			next_page_response = next_page_request.response

			page_no = Nokogiri::HTML(next_page_response.body, nil, "UTF-8")

			if page_no.css("#hiddenresult").size != 0
				html_table = page_no.css("#hiddenresult")
				mTown.current_rows_num = current_rows_num
				mTown.save
			else
				puts "nil html"
				mTown.is_crawl_finished = true
				mTown.save
				return
			end

			# puts next_page_response.body
		end


		# puts qry_land_response.body
		rawPage = RawPage.new
		# puts html_table.to_s
		rawPage.html = html_table.to_s
		rawPage.page_num = current_rows_num
		rawPage.county_id = mTown.county_id
		rawPage.town_id = mTown.id
		rawPage.save

		0.upto 199 do |item_num|

			item_num = item_num + current_rows_num - 200

			puts "current item num " + item_num.to_s

			sleep(1)

			# num = item_num - 1
			flag_url = "http://lvr.land.moi.gov.tw/N11/GetImage?action=0&flag=#{item_num}&time=61930"
			puts flag_url
			# get the flag position
			Typhoeus.get(
				flag_url,
				headers:{
					cookie: cookies
				}
			)


			xy_response = Typhoeus.post(
				"http://lvr.land.moi.gov.tw/N11/pro/getPointXY.jsp",
				params:{ 
					id: item_num
				},
				headers:{
					cookie: cookies
				}
			)


			rawItem = RawItem.new
			rawItem.raw_page_id = rawPage.id
			
			rawItem.item_num = item_num

			
			xy_body = xy_response.body
			xy_body = xy_body.gsub(" ","")
			xy_body = xy_body.gsub("\n","")

			rawItem.raw_xy = xy_body

			# puts xy_response.body
			# xy_body = xy_body.gsub("\n","")
			# puts xy_body
			# x = xy_body[0..xy_body.index("&")-1]
			# xy_body = xy_body[xy_body.index("&")+1..xy_body.length]
			# y = xy_body[0..xy_body.index("&")-1]

			puts  " item num "+ item_num.to_s  + " x y= " + xy_body

			sleep(1)

			

			# get detail 1. get token 2. get detail response
			token = getToken(cookies)

			# sleep(0.5)

			caseNo = context.call("doBase64",item_num.to_s)

			detail_request = Typhoeus::Request.new(
			  	"http://lvr.land.moi.gov.tw/N11/QryClass_getDetailData.action",
			  	method: :post,
			  	:params => { 
			  		'inType' => URI::encode("bGFuZA=="),
			  		'caseNo' => URI::encode(caseNo),
			  		'Qry_unit' => URI::encode("Mg=="),
			  		'struts.token.name' => URI::encode("token"),
			  		'token' => URI::encode(token)
			  	},
			  	headers:{
					cookie: cookies
				}
			)

			detail_request.run
			detail_response = detail_request.response



			if detail_response.code != 200
				puts "fail request detail"
				# puts detail_response.headers_hash
				# puts detail_response.body
				return
			else
				puts "Success crawl detail"
				# puts detail_response.code
				# puts detail_response.body
				rawItem.raw_detail = detail_response.body
				rawItem.save
			end
		end

	end

	def getToken(cookies)

			urlToken = "http://lvr.land.moi.gov.tw/N11/pro/setToken.jsp"

			tokenResponse = Typhoeus.post(
				urlToken,
				headers:{
					cookie: cookies
				}
			)

			if tokenResponse.code != 200
				puts "request denied"
				return
			else
				puts tokenResponse.code
				puts "request token " + urlToken
			end

			body = Nokogiri::HTML(tokenResponse.body)
			token = body.children[1].children[0].children[1]["value"]
			return token
	
	end


	task :perform_crawl_workder => :environment do

		initialize_towns_data()
		towns = Town.all
		towns.each do |town|
			RawDataWorker.perform_async(town.id)
		end

	end

	task :perform_crawl_workder_test => :environment do

		# initialize_towns_data()
		RawDataWorker.perform_async(335)
	
	end

	task :perform_crawl_workder_for_unfinished_towns => :environment do

		Town.where(" is_crawl_finished = false").each do |town|
			RawDataWorker.perform_async(town.id)
		end	
	
	end

	def initialize_towns_data()
		RawPage.delete_all
		RawItem.delete_all
		Town.all.each do |town|
			town.current_rows_num = 0
			town.is_crawl_finished = false
			town.save
		end
	end

	task :crawl_county_and_town => :environment do

		include Capybara::DSL

  		Capybara.current_driver = :selenium
		Capybara.app_host = 'http://lvr.land.moi.gov.tw/N11'
		page.visit '/homePage.action#dialog'
		click_on 'land'  # this be an Ajax button -- requires Selenium
	    fill_in 'rand_code', :with => STDIN.gets.chomp
	    # click_link '#'
	    find(:xpath, "//a[contains(@href,'#')]").click

	    page_no = Nokogiri::HTML(page.html)
	    citys = page_no.css("select#Qry_city").children
	    1.upto (citys.size-1) do |x|
	    	newCity = County.new
	    	newCity.name = citys[x].children.to_s.strip
	    	newCity.code = citys[x][:value]
	    	newCity.save
	    	# crawl town
	    	within '#Qry_city' do
  				find("option[value='#{newCity.code}']").click
			end
			page.html
			page_no = Nokogiri::HTML(page.html)
			towns = page_no.css("select#Qry_area_office")[0].children
			1.upto (towns.size-1) do |town_x|
				newTown = Town.new
				newTown.name = towns[town_x].children.to_s.strip
				newTown.code = towns[town_x][:value]
				newTown.county_id = newCity.id
				newTown.current_rows_num = 0
				newTown.is_crawl_finished = false
				newTown.save
				puts newCity.name + ":" + newTown.name
			end
	    end
  	end



	task :testToken => :environment do

		urlToken = "http://lvr.land.moi.gov.tw/N11/pro/setToken.jsp"

		cookies = "JSESSIONID=F99F7294F89E78BCF730ADA67BB4778B.jvm1; Path=/N11 \n slb_cookie=16951488.20480.0000; path=/"

		tokenResponse = Typhoeus.post(
			urlToken,
			headers:{
				cookie: cookies
			}
		)

		if tokenResponse.code != 200
			puts "request denied"
			return
		else
			puts tokenResponse.code
			puts "request token" + urlToken
		end

		puts body = Nokogiri::HTML(tokenResponse.body)

		puts body.children[1].children[0].children[1]["value"]

	end

	task :test_puts_town_year_price => :environment do

	  town_id = 1
		exchange_year = [101, 102]
		# ground_type_id = 1
		building_type_id = 1

		puts "位置: " + Town.find(town_id).name

		0.upto exchange_year.size-1 do |num|

			puts "The year: #{exchange_year[num]} "+ " " + BuildingType.find(building_type_id).name 

			1.upto 12 do |month|

				items = Realestate.where(" square_price IS NOT NULL and town_id = 1 and exchange_year = #{exchange_year[num]} and exchange_month = #{month} and building_type_id = #{building_type_id}")
				# cal average
				sum = 0.0
				items.each do |item|
					sum = sum + item.square_price
				end
				average = sum / items.size

				puts "#{month} 月: " + " #{average} 萬" 

			end

		end

	end


	# task :test => :environment do

	# 	keyword = "阿媽的話 簫"
	# 	keyword = keyword.strip.sub(" ", "+")
	# 	url = "http://www.google.com/search?q=#{keyword}"

	# 	headers = {
	# 		"user-agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5)",
	# 		"accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
	# 		"accept-charset" => "ISO-8859-1,utf-8;q=0.7,*;q=0.3",
	# 		"accept-encoding" => "gzip,deflate,sdch",
	# 		"accept-language" => "en-US,en;q=0.8",
	# 	}

	# 	response = Typhoeus.get(url, :headers => headers)

	# 	# check the status code of the response to make sure the request went well
	# 	if response.code != 200
	# 		puts "request denied"
	# 		return
	# 	else
	# 		puts "scraping " + url
	# 	end

	# 	dom = Nokogiri::HTML(response.body)

	# 	# each result is an <li> element with class="g" this is our wrapper
	# 	results = dom.css("li.g")

	# 	# iterate over each of the result wrapper elements
	# 	results.each { |result|
	# 		# the main link is an <h3> element with class="r"
	# 		result_anchor = result.css("h3.r").css("a")
	# 		puts result_anchor
	# 	}

	# end

end
