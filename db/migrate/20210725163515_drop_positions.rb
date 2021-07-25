class DropPositions < ActiveRecord::Migration[6.1]
  def change
    drop_table :positions
  end
end
