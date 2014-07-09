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

  def move_up
    regenerate_positions
    if previous_child = MetaKeyMetaTerm.find_by(meta_key_id: meta_key.id, position: position - 1)
      previous_child.update_attribute(:position, position)
      update_attribute(:position, position - 1)
    end
  end

  def move_down
    regenerate_positions
    if next_child = MetaKeyMetaTerm.find_by(meta_key_id: meta_key.id, position: position + 1)
      next_child.update_attribute(:position, position - 1)
      update_attribute(:position, position + 1)
    end
  end

  private

  def regenerate_positions
    MetaKeyMetaTerm.transaction do
      MetaKeyMetaTerm.where(meta_key_id: meta_key.id).order(:position).each_with_index do |mkmt, index|
        mkmt.update_attribute(:position, index)
      end
    end
  end
end
