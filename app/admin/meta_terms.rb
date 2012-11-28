# coding: utf-8
ActiveAdmin.register MetaTerm, sort_order: 'id'  do
  menu :parent => "Meta"

  #actions  :index, :new, :create, :edit, :update, :destroy

  scope :all, :default => true
  scope :with_meta_data
  scope :with_keywords

  index do
    column :id
    column :en_gb
    column :de_ch
    column :is_used do |x|
      status_tag (x.is_used? ? "Yes" : "No"), (x.is_used? ? :ok : :warning)
    end
    column :meta_data do |meta_term|
      count=meta_term.meta_data.count
      if count>0
        link_to "Transfer #{count} to …", transfer_meta_data_form_admin_meta_term_path(meta_term)
      end
    end
    column :keywords do |meta_term|
      count=meta_term.keywords.count
      if count>0
        link_to "Transfer #{count} to …", transfer_keywords_form_admin_meta_term_path(meta_term)
      end
    end
    column do |x|
      r = link_to "Edit", [:edit, :admin, x]
      unless x.is_used?
        r += " "
        r += link_to "Delete", [:admin, x], :method => :delete, :data => {:confirm => "Are you sure?"}
      end
      r
    end
  end

  ###################################################
  # Transferring keywords
  ###################################################
   
  member_action :transfer_keywords_form

  member_action :transfer_keywords , method: 'post'  do

    meta_term_originator= MetaTerm.find(params[:id])
    meta_term_receiver= MetaTerm.find(params[:id_receiver])

    ActiveRecord::Base.transaction do
      meta_term_originator.keywords.each do |keyword| 
        keyword.update_attribute :meta_term, meta_term_receiver
      end
    end

    redirect_to admin_meta_terms_path
  end



  ###################################################
  # Transferring meta_data 
  ###################################################

  member_action :transfer_meta_data_form

  member_action :transfer_meta_data , method: 'post'  do

    meta_term_originator= MetaTerm.find(params[:id])
    meta_term_receiver= MetaTerm.find(params[:id_receiver])

    ActiveRecord::Base.transaction do
      meta_term_receiver.meta_data << \
        meta_term_originator.meta_data \
        .where("id not in (#{meta_term_receiver.meta_data.select('"meta_data"."id"').to_sql})")
      meta_term_originator.meta_data.destroy_all
    end

    redirect_to admin_meta_terms_path
  end



end
