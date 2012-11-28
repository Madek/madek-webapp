ActiveAdmin.register MetaKey do
  menu :parent => "Meta"

  actions  :index, :new, :create, :edit, :update, :destroy

  index do
    column :label
    column :meta_datum_object_type
    column :is_dynamic
    column :terms do |x|
      ul
        x.meta_terms.each do |y|
          li y
        end
    end
    column :meta_key_definitions do |x|
      c = x.meta_key_definitions.count
      status_tag "#{c}", (c.zero? ? :warning : :ok)
    end
    column :meta_data do |x|
      c = x.meta_data.count
      status_tag "#{c}", (c.zero? ? :warning : :ok)
    end
    column do |x|
      r = link_to "Edit", [:edit, :admin, x]
      if x.is_deletable?
        r += " "
        r += link_to "Delete", [:admin, x], :method => :delete, :data => {:confirm => "Are you sure?"}
      end
      r
    end
  end

  form :partial => "form"

  member_action :update, :method => :post do
    @meta_key = MetaKey.find(params[:id])
    meta_terms_attributes = params[:meta_key].delete(:meta_terms_attributes)

    params[:reassign_term_id].each_pair do |k, v|
      next if v.blank?
      from = @meta_key.meta_terms.find(k)
      to = @meta_key.meta_terms.find(v)
      next if from == to
      from.reassign_meta_data_to_term(to, @meta_key)
      meta_terms_attributes.values.detect{|x| x[:id].to_i == from.id}[:_destroy] = 1
    end if params[:reassign_term_id]

    if params[:term_positions]
      positions = CGI.parse(params[:term_positions])["position[]"]
      positions.each_with_index do |id, i|
        # meta_terms_attributes.values.detect{|x| x[:id].to_i == id.to_i}[:position] = i+1
        @meta_key.meta_key_meta_terms.where(:meta_term_id => id).first.update_attributes(:position => i+1)
      end
    end

    meta_terms_attributes.each_value do |h|
      if h[:id].nil? and LANGUAGES.any? {|l| not h[l].blank? }
        term = MetaTerm.find_or_create_by_en_gb_and_de_ch(h)
        @meta_key.meta_terms << term
      elsif h[:_destroy].to_i == 1
        term = @meta_key.meta_terms.find(h[:id])
        @meta_key.meta_terms.delete(term)
      end
    end if meta_terms_attributes
 
    @meta_key.update_attributes(params[:meta_key])
    
    redirect_to [:admin, :meta_keys]
  end  
      
end
