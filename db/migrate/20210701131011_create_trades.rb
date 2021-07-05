class CreateTrades < ActiveRecord::Migration[6.1]
  def change
    create_table :trades do |t|
      t.string :symbol, null: false
      t.string :exchange
      t.string :currency, null: false, default: 'USD'
      t.decimal :price, null: false, default: 0
      t.float :quantity, null: false, default: 0
      t.decimal :commission, default: 0
      t.datetime :trade_date, null: false
      t.string :notes, limit: 2000

      t.timestamps
    end
  end
end
