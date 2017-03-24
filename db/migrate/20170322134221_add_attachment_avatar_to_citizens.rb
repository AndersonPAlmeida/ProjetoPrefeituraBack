class AddAttachmentAvatarToCitizens < ActiveRecord::Migration
  def self.up
    change_table :citizens do |t|
      t.attachment :avatar
    end
  end

  def self.down
    remove_attachment :citizens, :avatar
  end
end
