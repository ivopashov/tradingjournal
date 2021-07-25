class AddUserIdToTrades < ActiveRecord::Migration[6.1]
  def change
    add_reference :trades, :user
  end
end
