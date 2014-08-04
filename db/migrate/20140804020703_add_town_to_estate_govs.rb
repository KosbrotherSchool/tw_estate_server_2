class AddTownToEstateGovs < ActiveRecord::Migration
  def change
    add_column :estate_govs, :town, :string
  end
end
