class AddTradeIdAndPlatformToTrades < ActiveRecord::Migration[6.1]
  def change
    add_column :trades, :trade_id, :string
    add_column :trades, :platform, :string

    add_index :trades, [:trade_id, :platform], unique: true
  end
end
