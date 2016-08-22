class CreateJoinTableAccountsServicePlaces < ActiveRecord::Migration[5.0]
  def change
    create_join_table :accounts, :service_places do |t|
      # t.index [:account_id, :service_place_id]
      # t.index [:service_place_id, :account_id]
    end
  end
end
