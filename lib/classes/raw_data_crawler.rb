# encoding: utf-8
class RawDataCrawler

	require "rubygems"
	require "typhoeus"
	require "nokogiri"
	require "open-uri"
	require 'tesseract'

	def crawl_town_data(town_id, start_year, start_month, end_year, end_month)
	
		url = "http://lvr.land.moi.gov.tw/N11/ImageNumberN13?"

		cookies = nil


		# found towns which is_crawl_finished = false
		mTown = Town.find(town_id)
		mCounty = County.find(mTown.county_id)
		qry_city = mCounty.code
		qry_area_office = mTown.code

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
		# puts auto_login_code

		# login_code = STDIN.gets.chomp
		url = "http://lvr.land.moi.gov.tw/N11/login.action"

		response = Typhoeus.post(
			url,
			params:{ 
				rand_code: auto_login_code,
				command: "login",
				in_type: "land",
				formaturl: "",
			},
			headers:{
				cookie: cookies
			}
		)

		if response.code != 200
			puts "request denied"
			return
		else
			# puts response.code
			puts "scraping " + url
		end

		# dom = Nokogiri::HTML(response.body)
		# puts dom.css("body")

		# Call JavaScript Function
		source = open("http://lvr.land.moi.gov.tw/INC/js/qt_base64.js").read
		context = ExecJS.compile(source)
		# context.call("doBase64","C")
		qry_city = context.call("doBase64",qry_city)
		qry_area_office = context.call("doBase64",qry_area_office)
		qry_p_yyy_s = context.call("doBase64",start_year.to_s)
		qry_season_s = context.call("doBase64",start_month.to_s)
		qry_p_yyy_e = context.call("doBase64", end_year.to_s)
		qry_season_e = context.call("doBase64",end_month.to_s)

		# get token
		token = getToken(cookies)	

		qry_land_url = "http://lvr.land.moi.gov.tw/N11/QryClass_land.action"

		qry_land_request = Typhoeus::Request.new(
		  	qry_land_url,
		  	method: :post,
		  	:params => { 
		  		'type' => URI::encode("UXJ5ZGF0YQ=="),
		  		'Qry_city' => URI::encode(qry_city),
		  		'Qry_area_office' => URI::encode(qry_area_office),
		  		'Qry_paytype' => URI::encode("MSwyLDMsNCw1"),
		  		'Qry_build' => "",
		  		'Qry_price_s' => "",
		  		'Qry_price_e' => "",
		  		'Qry_unit_price_s' => "",
		  		'Qry_unit_price_e' => "",
		  		'Qry_p_yyy_s' => URI::encode(qry_p_yyy_s),
		  		'Qry_p_yyy_e' => URI::encode(qry_p_yyy_e),
		  		'Qry_season_s' => URI::encode(qry_season_s),
		  		'Qry_season_e' => URI::encode(qry_season_e),
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

		# puts qry_land_request.url

		qry_land_request.run

		qry_land_response = qry_land_request.response

		# puts qry_land_response.body

		if qry_land_response.code != 200		
			puts "request denied"
			RawDataWorker.perform_async(town_id)
			return
		else
			# puts qry_land_response.code
			puts "request land data: " + qry_land_url
			page_no = Nokogiri::HTML(qry_land_response.body, nil, "UTF-8")
			if page_no.css("#hiddenresult").size == 0
				
				if qry_land_response.body.index("description")
					puts "zero data"
				else
					puts "fail login"
					RawDataWorker.perform_async(town_id)
				end
				
				return
			end
		end

		# get current_rows_num & start with current rows
		current_rows_num = mTown.current_rows_num + 200

		if current_rows_num == 200
			puts "crawl first 200 items"
			page_no = Nokogiri::HTML(qry_land_response.body, nil, "UTF-8")
			html_table = page_no.css("#hiddenresult")
			mTown.current_rows_num = current_rows_num
			mTown.save
			RawDataWorker.perform_async(town_id)
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
			  		'Qry_city' => URI::encode(qry_city),
			  		'Qry_area_office' => URI::encode(qry_area_office),
			  		'Qry_unit' => 2,
			  		'rowno' => current_rows_num
			  	},
			  	headers:{
					cookie: cookies
				}
			)

			# puts next_page_request.url

			next_page_request.run
			next_page_response = next_page_request.response

			page_no = Nokogiri::HTML(next_page_response.body, nil, "UTF-8")

			if page_no.css("#hiddenresult").size != 0
				html_table = page_no.css("#hiddenresult")
				mTown.current_rows_num = current_rows_num
				mTown.save
				RawDataWorker.perform_async(town_id)
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
			
			rawItem.item_num = item_num + 1

			
			xy_body = xy_response.body
			xy_body = xy_body.gsub(" ","")
			xy_body = xy_body.gsub("\n","")
			xy_body = xy_body.gsub("\r","")

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
			puts "this token: " + token

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
				if !xy_body.index("html")
					rawItem.save
				end				
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
				puts "fail request token"
				return
			else
				# puts tokenResponse.code
				puts "success request token " + urlToken
			end

			body = Nokogiri::HTML(tokenResponse.body)
			token = body.children[1].children[0].children[1]["value"]
			return token
	
	end

end