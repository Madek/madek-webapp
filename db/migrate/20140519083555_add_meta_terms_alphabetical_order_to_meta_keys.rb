class AddMetaTermsAlphabeticalOrderToMetaKeys < ActiveRecord::Migration
  def change
    add_column :meta_keys, :meta_terms_alphabetical_order, :boolean, default: true

    MetaKey.for_meta_terms.each do |meta_key|
      meta_key.meta_terms.reorder('term').map(&:id).each_with_index do |meta_term_id, index|
        meta_key.meta_key_meta_terms.find_by(meta_term_id: meta_term_id).update_attribute(:position, index)
      end
      meta_key.update_attribute(:meta_terms_alphabetical_order, true)
    end
  end
end
