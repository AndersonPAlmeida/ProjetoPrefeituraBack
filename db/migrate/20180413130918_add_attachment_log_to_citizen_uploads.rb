class AddAttachmentLogToCitizenUploads < ActiveRecord::Migration
  def self.up
    change_table :citizen_uploads do |t|
      t.attachment :log
    end
  end

  def self.down
    remove_attachment :citizen_uploads, :log
  end
end
