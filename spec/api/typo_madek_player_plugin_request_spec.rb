require 'spec_helper'

describe "requests of the typo madek player plugin" do

  # !!!!!!!!!!
  # in the case that you dont know the difference between :each and :all
  # read here: https://www.relishapp.com/rspec/rspec-core/v/2-2/docs/hooks/before-and-after-hooks
  before :each do 
    FactoryGirl.create :meta_context_core
    FactoryGirl.create :meta_key_public_caption
    FactoryGirl.create :meta_key_copyright_status
    FactoryGirl.create :meta_key_copyright_usage
    FactoryGirl.create :meta_key_copyright_url
    @user = FactoryGirl.create :user
    @media_set = FactoryGirl.create :media_set, :user => @user
    @media_set.update_attribute :view, true
    @media_set.meta_data.create :meta_key => MetaKey.find_by_id("title"), :value => "My Set"
    @media_set.meta_data.create :meta_key => MetaKey.find_by_id("author"), :value => @user.name
    5.times do
      me = FactoryGirl.create :media_entry, :user => @user
      me.update_attribute :view, true
      me.meta_data.create :meta_key => MetaKey.find_by_id("title"), :value => Faker::Lorem.words(1).join(' ')
      @media_set.child_media_resources << me
    end
    MediaResource.reindex
  end

  describe "search a set" do

    it "should responds with matched sets" do
      with = {:media_type => true, :image => {:as => "base64", :size => "small"}, :meta_data => {:meta_key_ids => ["author"]}}
      get "/media_resources.json", {type: "media_sets", search: @media_set.title, with: with}
      json = JSON.parse(response.body)
      ms = json["media_resources"].find{|mr| mr["id"] == @media_set.id}
      expect(ms["type"]).to eq "media_set"
      expect(ms.has_key? "image").to eq true
      expect(ms.has_key? "meta_data").to eq true
      expect(ms["meta_data"].find{|md| md["name"] == "author"}["value"]).to eq @user.name
      expect(ms["media_type"]).to eq "set"
    end
  end

  describe "play a set" do

    it "should responds with child_media_resources of a set" do
      meta_key_ids = ["title", "subtitle", "author", "portrayed object dates", "public caption", "copyright notice",
                      "copyright status","copyright usage","copyright url"]
      with = {:children => {:public => true, :with => {:media_type => true, :meta_data => {:meta_key_ids => meta_key_ids}}}}
      get "/media_resources.json", {ids: [@media_set.id], with: with}
      json = JSON.parse(response.body)
      ms = json["media_resources"][0]
      expect(ms["id"]).to eq @media_set.id
      children = ms["children"]["media_resources"]
      expect(children.size).to be > 0
      children.each do |child|
        expect(@media_set.child_media_resources.map(&:id).include? child["id"]).to be_true
        expect(child.has_key? "type").to eq true
        expect(child.has_key? "meta_data").to eq true
        meta_key_ids.each do |mkid|
          expect(child["meta_data"].find{|md| md["name"] == mkid}.nil?).to be_false
        end
      end
    end
  end
end

describe do
  it "IS NOT THE IDEA TO CHANGE THIS TEST" do
    (File.open(__FILE__).read["require 'spec_helper'\n\ndescribe \"requests of the typo madek player plugin\" do\n\n  # !!!!!!!!!!\n  # in the case that you dont know the difference between :each and :all\n  # read here: https://www.relishapp.com/rspec/rspec-core/v/2-2/docs/hooks/before-and-after-hooks\n  before :each do \n    FactoryGirl.create :meta_context_core\n    FactoryGirl.create :meta_key_public_caption\n    FactoryGirl.create :meta_key_copyright_status\n    FactoryGirl.create :meta_key_copyright_usage\n    FactoryGirl.create :meta_key_copyright_url\n    @user = FactoryGirl.create :user\n    @media_set = FactoryGirl.create :media_set, :user => @user\n    @media_set.update_attribute :view, true\n    @media_set.meta_data.create :meta_key => MetaKey.find_by_id(\"title\"), :value => \"My Set\"\n    @media_set.meta_data.create :meta_key => MetaKey.find_by_id(\"author\"), :value => @user.name\n    5.times do\n      me = FactoryGirl.create :media_entry, :user => @user\n      me.update_attribute :view, true\n      me.meta_data.create :meta_key => MetaKey.find_by_id(\"title\"), :value => Faker::Lorem.words(1).join(' ')\n      @media_set.child_media_resources << me\n    end\n    MediaResource.reindex\n  end\n\n  describe \"search a set\" do\n\n    it \"should responds with matched sets\" do\n      with = {:media_type => true, :image => {:as => \"base64\", :size => \"small\"}, :meta_data => {:meta_key_ids => [\"author\"]}}\n      get \"/media_resources.json\", {type: \"media_sets\", search: @media_set.title, with: with}\n      json = JSON.parse(response.body)\n      ms = json[\"media_resources\"].find{|mr| mr[\"id\"] == @media_set.id}\n      expect(ms[\"type\"]).to eq \"media_set\"\n      expect(ms.has_key? \"image\").to eq true\n      expect(ms.has_key? \"meta_data\").to eq true\n      expect(ms[\"meta_data\"].find{|md| md[\"name\"] == \"author\"}[\"value\"]).to eq @user.name\n      expect(ms[\"media_type\"]).to eq \"set\"\n    end\n  end\n\n  describe \"play a set\" do\n\n    it \"should responds with child_media_resources of a set\" do\n      meta_key_ids = [\"title\", \"subtitle\", \"author\", \"portrayed object dates\", \"public caption\", \"copyright notice\",\n                      \"copyright status\",\"copyright usage\",\"copyright url\"]\n      with = {:children => {:public => true, :with => {:media_type => true, :meta_data => {:meta_key_ids => meta_key_ids}}}}\n      get \"/media_resources.json\", {ids: [@media_set.id], with: with}\n      json = JSON.parse(response.body)\n      ms = json[\"media_resources\"][0]\n      expect(ms[\"id\"]).to eq @media_set.id\n      children = ms[\"children\"][\"media_resources\"]\n      expect(children.size).to be > 0\n      children.each do |child|\n        expect(@media_set.child_media_resources.map(&:id).include? child[\"id\"]).to be_true\n        expect(child.has_key? \"type\").to eq true\n        expect(child.has_key? \"meta_data\").to eq true\n        meta_key_ids.each do |mkid|\n          expect(child[\"meta_data\"].find{|md| md[\"name\"] == mkid}.nil?).to be_false\n        end\n      end\n    end\n  end\nend\n\ndescribe do\n  it \"IS NOT THE IDEA TO CHANGE THIS TEST\" do\n    \(File.open(__FILE__).read\[\""]).should_not == nil
  end
end
