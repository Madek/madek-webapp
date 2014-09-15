class AppAdmin::KeywordsController < AppAdmin::BaseController
  before_action :set_filters, only: :index

  def index
    @keyword_terms = KeywordTerm \
      .with_count \
      .with_users_count \
      .with_date_of_creation \
      .page(params[:page]).per(12)

    @search_by = params[:search_by] == 'creator' ? :creator : :term

    if @search_term.present?
      if @search_by == :term
        case params.try(:[], :sort_by) 
        when 'trgm_rank'
          @keyword_terms = @keyword_terms.trgm_rank_search(@search_term)
        when 'text_rank'
          @keyword_terms = @keyword_terms.text_rank_search(@search_term)
        else
          @keyword_terms = @keyword_terms.text_search(@search_term)
        end
      else
        @keyword_terms = @keyword_terms.with_creators(@search_term)
      end
    end

    case @sort_by
    when :used_times_asc
      @keyword_terms = @keyword_terms.order("keywords_count")
    when :used_times_desc
      @keyword_terms = @keyword_terms.order("keywords_count DESC")
    when :created_at_asc
      @keyword_terms = @keyword_terms.order("date_of_creation")
    when :created_at_desc
      @keyword_terms = @keyword_terms.order("date_of_creation DESC")
    when :trgm_rank, :text_rank
      raise "Search term must not be blank!" if @search_term.blank?
    end

  rescue => e
    @keyword_terms = KeywordTerm.with_count
    @error_message = e.to_s
  end

  def edit
    @keyword_term = KeywordTerm.find(params[:id])
  end

  def update
    begin
      @keyword_term = KeywordTerm.find(params[:id])
      @keyword_term.update(keyword_params)

      redirect_to app_admin_keywords_url(search_term: nil), flash: {success: "The keyword term has been updated."}
    rescue => e
      redirect_to app_admin_keywords_url, flash: {error: e.to_s}
    end
  end

  def form_transfer_resources
    @keyword_term = KeywordTerm.find(params[:id])
  end

  def transfer_resources
    begin
      @keyword_term_originator = KeywordTerm.find params[:id]
      @keyword_term_receiver   = KeywordTerm.find params[:id_receiver]

      ActiveRecord::Base.transaction do
        @keyword_term_originator.keywords.each do |keyword|
          keyword.update_attribute(:keyword_term, @keyword_term_receiver)
        end
      end
      redirect_to app_admin_keywords_path, flash: {success: "The keyword term's resources have been transferred."}
    rescue => e
      redirect_to app_admin_keywords_path, flash: {error: e.to_s}
    end
  end

  def destroy
    begin 
      keyword_term = KeywordTerm.find(params[:id])
      raise "Cannot delete an used keyword." unless keyword_term.keywords.count.zero?
      keyword_term.destroy

      redirect_to app_admin_keywords_url, flash: {success: "The keyword term has been destroyed."}
    rescue => e
      redirect_to app_admin_keywords_url, flash: {error: e.to_s} 
    end
  end

  def users
    @keyword_term = KeywordTerm.find(params[:id])
    @users = User.where(%<users.id IN (#{@keyword_term.keywords.select('"keywords"."user_id"').to_sql})>)
  end

  def default_url_options(options={})
    {
      :search_term => params.try(:[], :search_term),
      :sort_by     => params.try(:[], :sort_by).try(&:to_sym),
      :search_by   => params.try(:[], :search_by).try(&:to_sym)
    }
  end

  private

  def keyword_params
    params.require(:keyword).permit(:id, :term)
  end

  def set_filters
    @search_term    = params[:search_term]
    @sort_by        = params[:sort_by].to_sym rescue :created_at_desc
  end
end
