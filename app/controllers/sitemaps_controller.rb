class SitemapsController < ApplicationController
  def show
    @media_entries = MediaEntry.viewable_by_public.limit(10)
    @collections = Collection.viewable_by_public.limit(10)

    respond_to do |format|
      format.xml do
        render template: 'sitemaps/show', layout: false
      end
    end
  end
end
