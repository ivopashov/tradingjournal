class CreateStockSnapshot < ActiveRecord::Migration[6.1]
  def change
    create_table :stock_snapshots do |t|
      t.string :ticker, null: false
      t.timestamp :timestamp, null: false

      t.decimal :close, default: 0
      t.decimal :volume, default: 0
      t.decimal :open, default: 0
      t.decimal :high, default: 0
      t.decimal :low, default: 0
      t.decimal :sma20, default: 0
      t.decimal :sma50, default: 0
      t.decimal :sma200, default: 0
      t.decimal :volume50, default: 0

      t.float :rsi, default: 0

      t.index [:ticker, :timestamp], unique: true

      t.timestamps
    end
  end
end
