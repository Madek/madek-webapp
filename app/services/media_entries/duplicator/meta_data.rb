module MediaEntries::Duplicator::MetaData
  private

  def copy_meta_data
    copy_meta_data_text
    copy_meta_data_keywords
    copy_meta_data_people
    copy_meta_data_roles
    originator.meta_data
  end

  def copy_meta_data_text
    originator.meta_data.where(type: text_meta_datum_types).each do |md|
      new_md = md.dup
      new_md.media_entry = media_entry
      if md.meta_key_id == 'madek_core:title'
        new_md.string = [md.string, I18n.t(:media_entry_duplicator_md_title_suffix)].join(' ')
      end
      new_md.save!
    end
  end

  def copy_meta_data_keywords
    originator.meta_data.where(type: 'MetaDatum::Keywords').each do |md|
      new_md = md.dup
      new_md.media_entry = media_entry
      new_md.save!

      md.meta_data_keywords.each do |mdk|
        new_mdk = mdk.dup
        new_mdk.meta_datum = new_md
        new_mdk.save!
      end
    end
  end

  def copy_meta_data_people
    originator.meta_data.where(type: 'MetaDatum::People').each do |md|
      new_md = md.dup
      new_md.media_entry = media_entry
      new_md.save!

      md.meta_data_people.each do |mdp|
        new_mdp = mdp.dup
        new_mdp.meta_datum = new_md
        new_mdp.save!
      end
    end
  end

  def copy_meta_data_roles
    originator.meta_data.where(type: 'MetaDatum::Roles').each do |md|
      new_md = md.dup
      new_md.media_entry = media_entry
      new_md.save!

      md.meta_data_roles.each do |mdr|
        new_mdr = mdr.dup
        new_mdr.meta_datum = new_md
        new_mdr.save!
      end
    end
  end

  def text_meta_datum_types
    %w(
      MetaDatum::Text
      MetaDatum::TextDate
      MetaDatum::JSON
    )
  end
end
