class AddExchangeDateToRealestates < ActiveRecord::Migration
  def change
    add_column :realestates, :exchange_date, :integer
  end
end
