class RemoveDateTimeFromLocTemp < ActiveRecord::Migration[6.0]
  def change

    remove_column :loc_temps, :date, :date

    remove_column :loc_temps, :time, :time
  end
end
