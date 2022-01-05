class AddDateToStockSnapshots < ActiveRecord::Migration[6.1]
    def change
        add_column :stock_snapshots, :date, :date, null: false
        add_index :stock_snapshots, [:ticker, :date]
    end
end
