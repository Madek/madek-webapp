class DropMetaFields < ActiveRecord::Migration
  include MigrationHelpers

  def up

    change_table :meta_contexts do |t|
      t.belongs_to  :label, :null => false
      t.belongs_to  :description
    end

    change_table :meta_key_definitions do |t|
      t.belongs_to  :label
      t.belongs_to  :description
      t.belongs_to  :hint
      t.text        :settings # serialized
    end

    #####################################################

    MetaContext.reset_column_information
    MetaKeyDefinition.reset_column_information

    MetaContext.all.each do |context|
      context.meta_key_definitions.each do |mkd|
        YAML.load(mkd.meta_field).ivars.each_pair do |k,v|
          mkd.send("#{k}=", v)
        end
        mkd.save
      end
      
      YAML.load(context.meta_field).ivars.each_pair do |k,v|
        context.send("#{k}=", v)
      end
      context.save
    end

    #####################################################

    add_fkey_referrence_constraint :meta_contexts, :meta_terms, :label_id
    add_fkey_referrence_constraint :meta_contexts, :meta_terms, :description_id

    add_fkey_referrence_constraint :meta_key_definitions, :meta_terms, :label_id
    add_fkey_referrence_constraint :meta_key_definitions, :meta_terms, :description_id
    add_fkey_referrence_constraint :meta_key_definitions, :meta_terms, :hint_id

    #####################################################

    change_table :meta_contexts do |t|
      t.remove :meta_field
    end

    change_table :meta_key_definitions do |t|
      t.remove :meta_field
    end

  end

  def down
  end
  
end
