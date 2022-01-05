class AddUserIdToHeatMaps < ActiveRecord::Migration[6.1]
  def change
    add_reference :heat_maps, :user
  end
end
