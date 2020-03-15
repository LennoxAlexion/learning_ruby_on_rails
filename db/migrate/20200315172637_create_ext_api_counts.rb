class CreateExtApiCounts < ActiveRecord::Migration[6.0]
  def change
    create_table :ext_api_counts do |t|
      t.integer :count

      t.timestamps
    end
  end
end
