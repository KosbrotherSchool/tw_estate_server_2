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


end