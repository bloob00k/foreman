class AddMetadataIdToSubnet < ActiveRecord::Migration
  def change
    add_column :subnets, :metadata_id, :integer
  end
end
