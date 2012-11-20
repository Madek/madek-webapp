class MetaTermsDatatable
  delegate :params, :h, :link_to, :number_to_currency, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: MetaTerm.count,
      iTotalDisplayRecords: meta_terms.total_entries,
      aaData: data
    }
  end

private

  def data
    meta_terms.map do |mt|
      [
        mt.id,
        
        mt.de_ch,

        mt.en_gb, 

        if  mt.meta_data.count == 0
          "" 
        else
          link_to("Transfer #{mt.meta_data.count} to ...", 
                  @view.meta_data_transfer_form_admin_term_path(mt), 
                  :class => "buttons", :remote => true, :"data-type" => "html")
        end,

        if mt.keywords.count == 0
          ""
        else
          link_to("Transfer #{mt.keywords.count} to ...", 
                  @view.keywords_transfer_form_admin_term_path(mt), 
                  :class => "buttons", :remote => true, :"data-type" => "html")
        end,

        mt.is_used?,

        link_to(@view._("Edit"), @view.edit_admin_term_path(mt), 
                class: "buttons", remote: true, :"data-type" => "html"),

        if mt.is_used? 
          ""
        else
          link_to("Delete", @view.admin_term_path(mt), 
                  :class => "buttons", :method => :delete, :data => {:confirm => "Sind Sie sicher?"}) 
        end
      ]
    end
  end

  def meta_terms
    @meta_terms ||= fetch_meta_terms
  end

  def fetch_meta_terms
    meta_terms = MetaTerm.order("#{sort_column} #{sort_direction}")
    meta_terms = meta_terms.page(page).per_page(per_page)
    if params[:sSearch].present?
      meta_terms = meta_terms.where("de_ch ilike :search OR en_gb ilike :search", search: "%#{params[:sSearch]}%")
    end
    meta_terms
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[id de_ch en_gb]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
