class ExploreController < ApplicationController

  def index
    # simple lists, no interaction, no params
    list_conf = { interactive: false }
    @get = Pojo.new(
      media_entries: Presenters::MediaEntries::MediaEntries.new(
        policy_scope(MediaEntry.all), current_user, list_conf: list_conf),
      collections: Presenters::Collections::Collections.new(
        policy_scope(Collection.all), current_user, list_conf: list_conf))
    # TMP: disabled:
    #   filter_sets: Presenters::FilterSets::FilterSets.new(
    #     policy_scope(MediaEntry), current_user, list_conf: list_conf))

    respond_with @get
  end

end
