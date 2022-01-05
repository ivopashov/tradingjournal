class CreateHeatMap < ActiveRecord::Migration[6.1]
  def change
    create_table :heat_maps, id: :string do |t|
      t.string :tickers, null: false
      t.string :name, null: false
      t.timestamps
    end
  end
end
