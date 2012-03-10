class MetaKeyMetaTerm < ActiveRecord::Base
  self.table_name = 'meta_keys_meta_terms'

  belongs_to    :meta_key
  belongs_to    :meta_term, :class_name => "MetaTerm"

  before_validation do
    self.position = self.next_position if self.position.zero?
  end

  def next_position
    self.class.where(:meta_key_id => meta_key_id).maximum(:position).try(:next).to_i
  end
  
end
