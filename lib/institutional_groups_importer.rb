module InstitutionalGroupsImporter

  class << self

    def reload!
      load Rails.root.join(__FILE__)
    end

    def module_path # for convenient reloading
      Rails.root.join(__FILE__)
    end

    def import!
      ActiveRecord::Base.transaction do
        import_igroups = \
          JSON.load ENV['FILE'] || Rails.root.join('db', 'ldap.json')
        import_ids = \
          Set.new(import_igroups.map { |ig| ig['institutional_group_id'] })
        InstitutionalGroup.find_in_batches do |db_igroups|
          db_igroups.each do |db_igroup|
            next if import_ids.include? db_igroup.institutional_group_id
            Rails.logger.warn "Database institutional_groups includes \
                              #{db_igroup} \
                              but import institutional_groups does not"
          end
        end
        import_igroups.each do |igroup|
          db_igroup = \
            InstitutionalGroup
              .find_or_initialize_by \
                institutional_group_id: igroup['institutional_group_id']
          db_igroup_relevant_attributes = \
            db_igroup.slice('institutional_group_id',
                            'name',
                            'institutional_group_name')
          if not db_igroup.persisted?
            Rails.logger.info "The InstitutionalGroup #{igroup} will be imported."
          elsif  igroup !=  db_igroup_relevant_attributes
            Rails
              .logger
              .info "The InstitutionalGroup #{igroup} \
                    will be updated, from #{db_igroup_relevant_attributes}"
          end
          db_igroup.update_attributes! igroup
        end
      end
    end
  end
end
