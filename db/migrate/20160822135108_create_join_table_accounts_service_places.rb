class CreateJoinTableAccountsServicePlaces < ActiveRecord::Migration[5.0]
  def change
    create_join_table :accounts, :service_places do |t|
      t.index [:account_id, :service_place_id], name: "idx_accounts_service_places"
      t.index [:service_place_id, :account_id], name: "idx_service_places_accounts"
    end
  end
end
