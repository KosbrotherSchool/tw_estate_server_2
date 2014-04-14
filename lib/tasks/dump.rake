# config = ActiveRecord::Base.connection.current_database
# database = config.database_configuration[RAILS_ENV]["database"]

namespace :dump do
  	task :in => ["db:drop","db:create","db:migrate","db:data:load"]

  	#rake db:dump
  	desc "dumps the database to a sql file"
  	task :dump => :environment do

	  database = ActiveRecord::Base.connection.current_database

    	puts "Creating #{database}.sql file."
    	`sqlite3 #{database} .dump > #{database}.sql`
  	end

  	task :dump_table => :environment do
	  	sql  = "SELECT * FROM %s"
	  	skip_tables = ["schema_info"]
	  	ActiveRecord::Base.establish_connection("development")
	  	tables=ENV['TABLES'].split(',')
	  	tables ||= (ActiveRecord::Base.connection.tables - skip_tables)

	  	puts tables

	  	tables.each do |table_name|
	    	i = "000"
	    	File.open("#{Rails.root}/test/fixtures/#{table_name}.yml", 'w') do |file|
	      		data = ActiveRecord::Base.connection.select_all(sql % table_name)
	      		file.write data.inject({}) { |hash, record|
	        		hash["#{table_name}_#{i.succ!}"] = record
	        		hash
	      		}.to_yaml
	    	end
	  	end
	end


end