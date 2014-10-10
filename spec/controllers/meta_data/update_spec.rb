require 'spec_helper'


describe MetaDataController do
  include Controllers::Shared

  before :all do
    FactoryGirl.create :usage_term

    FactoryGirl.create :meta_key, id: "copyright status", :meta_datum_object_type => "MetaDatumCopyright"

    @cr_std_root= Copyright.create! YAML.load %{
      is_default: false
      is_custom: false
      label: Urheberrechtlich geschützt (standardisierte Lizenz) }

    @cr_alle_rechte_vorbehalten= Copyright.create! ({parent: @cr_std_root}).merge(YAML.load %{
      is_default: true
      is_custom: false
      label: Alle Rechte vorbehalten
      usage: Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.
      url: http://www.copyright.ch })

    @user = FactoryGirl.create :user
    @media_entry = FactoryGirl.create :media_entry, user: @user
  end

  after :all do
    truncate_tables
  end

  describe "update to the default copyright" do
    it "is successful and the default " do
      put 'update', {media_resource_id: @media_entry.id, id: "copyright status", value: @cr_alle_rechte_vorbehalten.id}, valid_session(@user)
      expect(response).to be_success
      expect(@media_entry.reload.meta_data.get("copyright status").value).to be== @cr_alle_rechte_vorbehalten
    end
  end

  describe "update to the std copyright" do
    it "is successful and sets the std " do
      put 'update', {media_resource_id: @media_entry.id, id: "copyright status", value: @cr_std_root.id}, valid_session(@user)
      expect(response).to be_success
      expect(@media_entry.reload.meta_data.get("copyright status").value).to be== @cr_std_root
    end
  end

end
