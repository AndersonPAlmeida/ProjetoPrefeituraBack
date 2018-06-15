class AddAttachmentAvatarToCityHalls < ActiveRecord::Migration[5.0]
  def self.up
    change_table :city_halls do |t|
      t.attachment :avatar
    end
  end

  def self.down
    remove_attachment :city_halls, :avatar
  end
end
