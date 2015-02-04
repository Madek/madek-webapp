class MigrateMetaTermsToVocables < ActiveRecord::Migration
  class MetaTerm < ActiveRecord::Base
    has_and_belongs_to_many :meta_keys
  end

  class MetaKey <ActiveRecord::Base 
    has_and_belongs_to_many :meta_terms
    belongs_to :vocabulary
    has_many :meta_key_definitions
    has_many :contexts, through: :meta_key_definitions
  end

  class MetaKeyDefinition < ActiveRecord::Base
    belongs_to    :context, foreign_key: :context_id
    belongs_to    :meta_key
  end

  class Context < ActiveRecord::Base
  end

  class MetaDatum < ActiveRecord::Base
    self.inheritance_column = false

    has_and_belongs_to_many :vocables,
      join_table: :meta_data_vocables, 
      foreign_key: :meta_datum_id, 
      association_foreign_key: :vocable_id

    has_and_belongs_to_many :meta_terms,
      join_table: :meta_data_meta_terms, 
      foreign_key: :meta_datum_id, 
      association_foreign_key: :meta_term_id

    belongs_to :meta_key
  end

  class Vocabulary < ActiveRecord::Base
    has_many :meta_keys
    has_many :vocables, through: :meta_keys
  end

  class Vocable < ActiveRecord::Base
    belongs_to :meta_key
  end

  def change

    create_table :vocabularies, id: :string do |t|
      t.text :label
      t.text :description
    end

    add_column :meta_keys, :vocabulary_id, :string

    create_table :vocables, id: :uuid do |t|
      t.string :meta_key_id
      t.index :meta_key_id

      t.text :term
    end

    create_table :meta_data_vocables, id: false do |t|
      t.uuid :meta_datum_id
      t.uuid :vocable_id
      t.index [:meta_datum_id, :vocable_id], unique: true
      t.index [:vocable_id, :meta_datum_id]
    end

    add_column :meta_keys, :vocables_are_user_extensible, :bool, default: false

    Vocable.reset_column_information
    Vocabulary.reset_column_information
    MetaKey.reset_column_information
    MetaDatum.reset_column_information
    MetaTerm.reset_column_information
    MetaKeyDefinition.reset_column_information

    MetaDatum.joins(:meta_key) \
      .where("meta_keys.meta_datum_object_type = 'MetaDatum::Vocables'") \
      .find_each do |meta_datum|
        meta_key = meta_datum.meta_key
        # puts "meta_key: #{meta_key.attributes}"
        meta_key.meta_key_definitions.each do |mkd|
          vocabulary_id=mkd.context.id.downcase
          # puts "vocabulary_id: #{vocabulary_id}"
          new_id_meta_key_part= meta_key.id.downcase.gsub(/\s+/,'_').gsub(/-/,'_').gsub(/_+/,'_')
          new_meta_key_id= "#{vocabulary_id}:#{new_id_meta_key_part}"
          # puts "new_meta_key_id: #{new_meta_key_id}"
          vocabulary= Vocabulary.find_or_create_by(id: vocabulary_id)
          new_meta_key= MetaKey.find_or_create_by({id: new_meta_key_id, 
                                                   meta_datum_object_type:  'MetaDatum::Vocables',
                                                   label: mkd.label,
                                                   vocables_are_user_extensible: meta_key.is_extensible_list,
                                                   vocabulary: vocabulary})
          meta_datum.update_column :meta_key_id, new_meta_key_id
          meta_datum.meta_terms.each do |meta_term|
            vocable= Vocable.find_or_create_by(term: meta_term, meta_key: new_meta_key)
            meta_datum.vocables << vocable unless meta_datum.vocables.include? vocable
          end
        end
      end

    
  end
end
