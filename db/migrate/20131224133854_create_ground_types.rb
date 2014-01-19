class CreateGroundTypes < ActiveRecord::Migration
  def change
    create_table :ground_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
