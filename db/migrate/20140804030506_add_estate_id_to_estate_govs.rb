class AddEstateIdToEstateGovs < ActiveRecord::Migration
  def change
    add_column :estate_govs, :estate_id, :integer
  end
end
