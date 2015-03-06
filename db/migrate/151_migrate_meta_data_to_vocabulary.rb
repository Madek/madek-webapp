class MigrateMetaDataToVocabulary < ActiveRecord::Migration

  class MetaTerm < ActiveRecord::Base
    has_and_belongs_to_many :meta_keys
  end

  class MetaKey < ActiveRecord::Base
    has_and_belongs_to_many :meta_terms
    has_many :meta_data
    belongs_to :vocabulary
    has_many :meta_key_definitions
    has_many :contexts, through: :meta_key_definitions
  end

  class MetaKeyDefinition < ActiveRecord::Base
    belongs_to :context, foreign_key: :context_id
    belongs_to :meta_key
  end

  class Context < ActiveRecord::Base
    has_many :meta_key_definitions
  end

  class MetaDatum < ActiveRecord::Base
    self.inheritance_column = false

    has_and_belongs_to_many :users,
      join_table: :meta_data_users,
      foreign_key: :meta_datum_id,
      association_foreign_key: :user_id

    has_and_belongs_to_many :vocables,
      join_table: :meta_data_vocables,
      foreign_key: :meta_datum_id,
      association_foreign_key: :vocable_id

    has_and_belongs_to_many :meta_terms,
      join_table: :meta_data_meta_terms,
      foreign_key: :meta_datum_id,
      association_foreign_key: :meta_term_id

    has_and_belongs_to_many :people,
      join_table: :meta_data_people,
      foreign_key: :meta_datum_id,
      association_foreign_key: :person_id

    has_and_belongs_to_many :groups,
      join_table: :meta_data_groups,
      foreign_key: :meta_datum_id,
      association_foreign_key: :group_id

    has_many :keywords

    belongs_to :meta_key
  end

  class Person < ActiveRecord::Base
  end

  class Vocabulary < ActiveRecord::Base
    has_many :meta_keys
    has_many :vocables, through: :meta_keys
  end

  class Vocable < ActiveRecord::Base
  end

  def change
    @meta_data_count = 0
    begin 
      Vocable.reset_column_information
      Vocabulary.reset_column_information
      MetaKey.reset_column_information
      MetaDatum.reset_column_information
      MetaTerm.reset_column_information
      MetaKeyDefinition.reset_column_information

      MetaKey.order(:id).each do |meta_key|
        if meta_key.meta_key_definitions.count == 0

          orphan_vocabulary = Vocabulary.find_or_create_by id: 'orphans', label: 'Orphans',
            description: 'The related meta_keys in this vocabulary were not related to any context before the migration.'

          new_id_meta_key_part = meta_key.id.downcase.gsub(/\s+/, '_').gsub(/-/, '_').gsub(/_+/, '_')
          new_meta_key_id = "#{orphan_vocabulary.id}:#{new_id_meta_key_part}"

          new_meta_key = MetaKey.find_or_create_by(id: new_meta_key_id,
                                                   meta_datum_object_type:  meta_key.meta_datum_object_type,
                                                   vocables_are_user_extensible: meta_key.is_extensible_list,
                                                   vocabulary: orphan_vocabulary)
          Rails.logger.info "CREATED NEW META_KEY: #{new_meta_key.attributes}"

          clone_meta_key_data(meta_key, new_meta_key)

          new_meta_key.meta_data.reset

        else

          meta_key.meta_key_definitions.each do |meta_key_definition|
            Rails.logger.info "MIGRATING meta_key_definition: #{meta_key_definition.attributes}"

            context = meta_key_definition.context
            vocabulary_id = context.id.downcase.gsub(/\s+/, '_').gsub(/-/, '_').gsub(/_+/, '_').gsub(/[^a-z0-9\_\-]/, '')
            vocabulary = Vocabulary.find_or_create_by(id: vocabulary_id)
            vocabulary.update_attributes label: context.label, description: context.description

            new_id_meta_key_part = meta_key.id.downcase.gsub(/\s+/, '_').gsub(/-/, '_').gsub(/_+/, '_')
            new_meta_key_id = "#{vocabulary_id}:#{new_id_meta_key_part}"

            new_meta_key_attributes = { id: new_meta_key_id,
                                        meta_datum_object_type:  meta_key.meta_datum_object_type,
                                        label: meta_key_definition.label,
                                        description: meta_key_definition.description,
                                        hint: meta_key_definition.hint,
                                        is_required: meta_key_definition.is_required,
                                        length_max: meta_key_definition.length_max,
                                        length_min: meta_key_definition.length_min,
                                        position: meta_key_definition.position,
                                        input_type: meta_key_definition.input_type,
                                        vocables_are_user_extensible: meta_key.is_extensible_list,
                                        vocabulary: vocabulary }

            Rails.logger.info "CREATING NEW META_KEY: #{new_meta_key_attributes}"

            new_meta_key = MetaKey.find_or_create_by(new_meta_key_attributes)

            clone_meta_key_data meta_key, new_meta_key

            meta_key_definition.destroy
            new_meta_key.meta_data.reset

          end
        end
        meta_key.meta_data.reset
        meta_key.delete
      end
    rescue Exception => e
      Rails.logger.warn "#{e.class} #{e.message} #{e.backtrace.join(', ')}"
      raise e
    end
  end

  def clone_meta_key_data(meta_key, new_meta_key)
    meta_key.meta_data.each do |meta_datum|

      @meta_data_count+=1
      Rails.logger.info("#meta-datum: #{@meta_data_count} for #{new_meta_key.id}") if ((@meta_data_count % 1000) == 0)

      shared_attributes = meta_datum.slice(:string, :copyright_id, :media_entry_id, :collection_id, :filter_set_id, :type)
      new_meta_datum = MetaDatum.create! shared_attributes.merge(meta_key: new_meta_key)

      object_type = meta_key.meta_datum_object_type
      case meta_key.meta_datum_object_type

      when 'MetaDatum::Copyright', 'MetaDatum::Text', 'MetaDatum::TextDate'

      when 'MetaDatum::People'
        new_meta_datum.people = meta_datum.people
        new_meta_datum.save!
        new_meta_datum.people.reset
        meta_datum.people.reset

      when 'MetaDatum::Keywords'
        new_meta_datum.keywords = meta_datum.keywords
        new_meta_datum.save!
        new_meta_datum.keywords.reset
        meta_datum.keywords.reset

      when 'MetaDatum::Vocables'
        meta_datum.meta_terms.each do |meta_term|
          vocable = Vocable.find_or_create_by(term: meta_term.term, meta_key_id: new_meta_key.id)
          new_meta_datum.vocables << vocable unless meta_datum.vocables.include? vocable
        end
        meta_datum.meta_terms.reset 
        new_meta_datum.vocables.reset

      when 'MetaDatum::Groups'
        new_meta_datum.groups = meta_datum.groups
        new_meta_datum.save!
        new_meta_datum.groups.reset
        meta_datum.groups.reset

      when 'MetaDatum::Users'
        new_meta_datum.users = meta_datum.users
        new_meta_datum.save!
        new_meta_datum.users.reset
        meta_datum.users.reset

      else
        raise "MIGRATING meta_datum_object_type #{object_type} is pending"
      end

    end
  end

end
