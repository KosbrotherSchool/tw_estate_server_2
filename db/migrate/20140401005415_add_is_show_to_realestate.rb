class AddIsShowToRealestate < ActiveRecord::Migration
  def change
    add_column :realestates, :is_show, :boolean
  end
end
