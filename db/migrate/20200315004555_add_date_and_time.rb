class AddDateAndTime < ActiveRecord::Migration[6.0]
  def change
    add_column :loc_temps, :date, :date

    add_column :loc_temps, :time, :time
  end
end
