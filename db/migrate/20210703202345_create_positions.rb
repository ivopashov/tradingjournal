class CreatePositions < ActiveRecord::Migration[6.1]
  def change
    create_table :positions do |t|
      t.string :symbol, null: false, unique: true
      t.decimal :price, null: false, default: 0
      t.float :quantity, null: false, default: 0
      t.string :currency, null: false, default: 'USD'

      t.timestamps

      t.index :symbol, unique: true
    end
  end
end
