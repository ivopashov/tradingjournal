class CreateTradingAlert < ActiveRecord::Migration[6.1]
  def change
    create_table :trading_alerts do |t|
      t.string :ticker, null: false
      t.string :rule, null: false
      t.boolean :triggered, default: false
      t.timestamp :triggered_on
      t.timestamp :last_evaluated_on
      t.references :user

      t.timestamps
    end

    add_index :trading_alerts, [:triggered]
  end
end
