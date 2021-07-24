class AddIsImportedToTrades < ActiveRecord::Migration[6.1]
  def change
    add_column :trades, :is_imported, :boolean, default: false, null: false
  end
end
