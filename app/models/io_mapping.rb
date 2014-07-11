class IoMapping < ActiveRecord::Base
  belongs_to :io_interface
  belongs_to :meta_key

  def destroy
    IoMapping.connection.delete("DELETE FROM io_mappings WHERE io_interface_id"\
                                "= '#{self.io_interface_id}' AND meta_key_id ="\
                                " '#{self.meta_key_id}'")
  end
end
