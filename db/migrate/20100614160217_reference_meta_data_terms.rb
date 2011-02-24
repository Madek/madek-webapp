# -*- encoding : utf-8 -*-
class ReferenceMetaDataTerms < ActiveRecord::Migration
  def self.up
    MetaKey.where(:object_type => "Term").each do |key|
      key.meta_data.each do |meta_datum|
        value = Array(meta_datum.read_attribute(:value)).collect do |v|
          t = nil
          if v.is_a? String
            LANGUAGES.each do |lang|
              t ||= Term.where(lang => v).first
            end
          elsif v.is_a? Fixnum
            t = Term.where(:id => v).first
          end
          key.terms.include?(t) ? t.id : nil
        end
        meta_datum.update_attributes(:value => value)
      end
    end
  end

  def self.down
  end
end
