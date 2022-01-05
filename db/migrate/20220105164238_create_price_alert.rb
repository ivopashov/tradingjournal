class CreatePriceAlert < ActiveRecord::Migration[6.1]
  def change
    create_table :price_alerts do |t|
      t.string :name, null: false
      t.string :ticker, null: false
      t.string :comparison_operator, null: false
      t.decimal :price, null: false
      t.boolean :triggered, default: false
      t.timestamp :triggered_on
      t.references :user

      t.timestamps
    end

    add_index :price_alerts, [:ticker, :triggered]
    add_index :price_alerts, [:user_id, :triggered]
  end
end
