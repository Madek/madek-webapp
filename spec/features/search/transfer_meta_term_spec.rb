require 'rails_helper'
require 'spec_helper_feature_shared'

feature "Transferring resources between terms and searching for those terms."  do

  scenario "After transferring all media_resources from one term to an other
            the text search does reflect this transfer." , browser: :jsbrowser do

    @current_user= sign_in_as 'adam'

    @media_entry= create_a_media_entry
    set_media_resource_title @media_entry, "Ramon_s_Katz"

    the_meta_key= MetaKey.create!  \
      meta_datum_object_type: 'MetaDatumMetaTerms',
      id: 'the_meta_key' 

    mkd= MetaKeyDefinition.create! \
      context_id: 'core',
      label: "The meta key for testing MetaKeyMetaTerms",
      meta_key: the_meta_key

    meta_term_illwetritsch= MetaTerm.create! term: "Illwetritsch"
    MetaKeyMetaTerm.create! \
      meta_key: the_meta_key,
      meta_term: meta_term_illwetritsch

    meta_term_napdill= MetaTerm.create! term: "Napdill"
    MetaKeyMetaTerm.create! \
      meta_key: the_meta_key,
      meta_term: meta_term_napdill


    # associate the media_entry with Illwetritsch
    mdmts= MetaDatumMetaTerms.create! media_resource: @media_entry, meta_key: the_meta_key
    mdmts.meta_terms << meta_term_illwetritsch
    mdmts.save!

    @media_entry.reload.reindex
    click_on_text "Suche"
    find_input_with_name("terms").set("Illwetritsch")
    submit_form
    expect(page).to have_content "Ramon_s_Katz"

    # transfer media_resources and meta_keys from Illwetritsch to Napdill
    click_on_text "Adam Admin"
    click_on_text "Admin-Interface"
    click_on_text "Meta"
    click_on_text "Meta Terms"
    find_input_with_name("filter[search_terms]").set("Illwetritsch")
    submit_form
    click_on_text "Transfer"
    find_input_with_name("[id_receiver]").set meta_term_napdill.id
    submit_form

    
    visit "/search"
    find_input_with_name("terms").set("Illwetritsch")
    submit_form
    expect(page).not_to have_content "Ramon_s_Katz"


    visit "/search"
    find_input_with_name("terms").set("Napdill")
    submit_form
    expect(page).to have_content "Ramon_s_Katz"


  end


  require Rails.root.join "spec","features","search","shared.rb"
  include Features::Search::Shared

  def set_media_resource_authors media_resource, authors
    media_resource.meta_data \
      .create meta_key: MetaKey.find_by_id(:author), value: authors
  end


end


