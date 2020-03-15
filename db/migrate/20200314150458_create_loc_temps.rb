class CreateLocTemps < ActiveRecord::Migration[6.0]
  def change
    create_table :loc_temps do |t|
      t.integer :loc_id
      t.date :date
      t.time :time
      t.decimal :temperature

      t.timestamps
    end
  end
end
