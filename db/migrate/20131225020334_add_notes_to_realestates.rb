class AddNotesToRealestates < ActiveRecord::Migration
  def change
    add_column :realestates, :notes, :string
  end
end
