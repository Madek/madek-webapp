class RenameMetaDataTypes < ActiveRecord::Migration

  TYPE_MAP={
    'MetaDatumCopyright' => 'MetaDatum::Copyright',
    'MetaDatumCountry' => 'MetaDatum::Text',
    'MetaDatumDate' => 'MetaDatum::TextDate',
    'MetaDatumInstitutionalGroups' => 'MetaDatum::Groups',
    'MetaDatumKeywords' => 'MetaDatum::Keywords',
    'MetaDatumMetaTerms' => 'MetaDatum::Vocables',
    'MetaDatumPeople' => 'MetaDatum::People',
    'MetaDatumString' => 'MetaDatum::Text',
    'MetaDatumUsers' => 'MetaDatum::Users',
  }

  def up

    TYPE_MAP.each do |old_type,new_type|

      execute "UPDATE meta_keys
                  SET meta_datum_object_type = '#{new_type}'
                  WHERE meta_datum_object_type = '#{old_type}'"

      execute "UPDATE meta_data
                  SET type = '#{new_type}'
                  WHERE type = '#{old_type}'"

    end

    change_column :meta_keys, :meta_datum_object_type, :text, null: false, default: 'MetaDatum::Text'

    execute %[ALTER TABLE meta_data ADD CONSTRAINT check_valid_type CHECK 
          (type IN (#{TYPE_MAP.values.uniq.map{|s|"'#{s}'"}.join(', ')}));]

    execute %[ALTER TABLE meta_keys ADD CONSTRAINT check_valid_meta_datum_object_type CHECK 
          (meta_datum_object_type IN (#{TYPE_MAP.values.uniq.map{|s|"'#{s}'"}.join(', ')}));]

  end
end
