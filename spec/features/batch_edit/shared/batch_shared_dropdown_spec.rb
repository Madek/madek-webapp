def check_delete_success_message
  find('#app-alerts').find(
    '.ui-alert', text: I18n.t(:batch_destroy_resources_success))
end

def click_delete_question_ok
  find('.modal').find(
    '.primary-button',
    text: I18n.t(:batch_destroy_resources_ok)).click
end

def check_delete_question(media_entries_count, collections_count)
  text =
    I18n.t(:batch_destroy_resources_ask_1) \
    + ' ' + media_entries_count.to_s + I18n.t(:batch_destroy_resources_ask_2) \
    + ' ' + collections_count.to_s + I18n.t(:batch_destroy_resources_ask_3) \
    + ' ' + I18n.t(:batch_destroy_resources_ask_4)
  find('.modal', text: text)
end

def all_media_entry_permissions(user)
  {
    user: user,
    get_metadata_and_previews: true,
    get_full_size: true,
    edit_metadata: true,
    edit_permissions: true
  }
end

def all_collections_permissions(user)
  {
    user: user,
    get_metadata_and_previews: true,
    edit_metadata_and_relations: true,
    edit_permissions: true
  }
end

def give_all_permissions(resource, user)
  permissions =
    if resource.class == MediaEntry
      all_media_entry_permissions(user)
    elsif resource.class == Collection
      all_collections_permissions(user)
    else
      throw 'Not supported resource class: ' + resource.class.to_s
    end

  resource.user_permissions.create!(permissions)
  resource.save!
  resource.reload
end

def add_all_to_parent(resources, parent)
  resources.each do |resource|
    resource.parent_collections << parent
  end
end

def unpublish_media_entry(media_entry)
  media_entry.is_published = false
  media_entry.save!
  media_entry.reload
end

def check_resources_in_box(expected_resources)
  ui_resources = find('.ui-polybox').find('.ui-resources-page-items')
    .all('.ui-resource')

  actual_titles = ui_resources.map do |ui_resource|
    ui_resource.find('.ui-thumbnail-meta-title').text
  end

  expected_titles = expected_resources.map &:title

  expect(actual_titles.sort).to eq(expected_titles.sort)
end

def visit_resource(resource)
  visit self.send("#{resource.class.name.underscore}_path", resource)
end

def login(user)
  sign_in_as user
end

def create_user
  person = FactoryGirl.create(:person)
  FactoryGirl.create(
    :user,
    person: person
  )
end

def create_collection(title, user)
  collection = Collection.create!(
    get_metadata_and_previews: true,
    responsible_user: user,
    creator: user)
  MetaDatum::Text.create!(
    collection: collection,
    string: title,
    meta_key: meta_key_title,
    created_by: user)
  collection
end

def create_media_entry(title, user)
  media_entry = FactoryGirl.create(
    :media_entry,
    get_metadata_and_previews: true,
    responsible_user: user,
    creator: user)
  FactoryGirl.create(
    :media_file_for_image,
    media_entry: media_entry)
  MetaDatum::Text.create!(
    media_entry: media_entry,
    string: title,
    meta_key: meta_key_title,
    created_by: user)
  media_entry
end

def meta_key_title
  MetaKey.find_by(id: 'madek_core:title')
end
