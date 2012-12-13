ActiveAdmin.register MediaSet do

  controller do
    def scoped_collection
      # including subclasses (FilterSet)
      r = MediaResource.media_sets.includes(:user)
      r = r.search(params[:search]) if params[:search]
      r
    end
    
    def update
      super
      AppSettings.catalog_set_id = params[:catalog_set_id].to_i if params[:catalog_set_id]
      AppSettings.featured_set_id = params[:featured_set_id].to_i if params[:featured_set_id]
      AppSettings.splashscreen_slideshow_set_id = params[:splashscreen_slideshow_set_id].to_i if params[:splashscreen_slideshow_set_id]
    end
  end

  actions  :index, :new, :create, :edit, :update, :destroy
  
  index do
    column :type
    column :title, :sortable => false
    column :user
    column "Entries / Sets" do |x|
      c1, c2 = [x.child_media_resources.media_entries.count, x.child_media_resources.media_sets.count]
      s = "%d / %d" % [c1, c2]
      status_tag s, ([c1, c2].sum.zero? ? :warning : :ok)
    end
    column :public do |x|
      status_tag (x.view ? "Yes" : "No"), (x.view ? :ok : :warning)
    end
    column do |x|
      r = link_to "Edit", [:edit, :admin, x]
      if x.child_media_resources.empty?
        r += " "
        r += link_to "Delete", [:admin, x], :method => :delete, :data => {:confirm => "Are you sure?"}
      end
      r
    end
  end

  scope :all, :default => true
  scope :public do |records|
    records.where(:view => true)
  end
  scope :catalog_set do |records|
    records.where(:id => AppSettings.catalog_set_id)
  end
  scope :featured_set do |records|
    records.where(:id => AppSettings.featured_set_id)
  end
  scope :splashscreen_slideshow_set do |records|
    records.where(:id => AppSettings.splashscreen_slideshow_set_id)
  end
  scope :with_individual_contexts do |records|
    # TODO force active_admin to count(:distinct => true)
    #records.joins("INNER JOIN media_sets_meta_contexts ON media_sets_meta_contexts.media_set_id = media_resources.id").uniq
    records.joins("INNER JOIN media_sets_meta_contexts ON media_sets_meta_contexts.media_set_id = media_resources.id").group("media_resources.id")
  end

  form :partial => "form"

  config.filters = false
  sidebar :filters do
    render :partial => "filter"
  end
  
end
