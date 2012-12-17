# coding: utf-8
ActiveAdmin.register Person, sort_order: 'id' do
  menu :parent => "Subjects"

  #actions  :index, :new, :create, :edit, :update, :destroy

  index do
    column :id
    column :firstname
    column :lastname
    column :pseudonym
    column :is_group do |x|
      status_tag (x.is_group ? "Group" : "Person"), (x.is_group ? :warning : :ok)
    end
    column :user do |person|
      if person.user
        link_to person.user, [:edit, :admin, person.user]
      else
        link_to "Create User", new_admin_user_path(person_id: person), :class => "button" # alternative: new_admin_person_user_path(person)
      end
    end
    column :meta_data do |person|
      count=person.meta_data.count
      if count>0
        link_to ("Transfer <span class='meta_data_count'>#{count}</span> to …").html_safe, 
                transfer_meta_data_form_admin_person_path(person), :class => ["button","transfer_meta_data_link"]
      end
    end
    column do |person|
      html = link_to "Edit", [:edit, :admin, person]
      unless person.meta_data.count > 0  or person.user
        html+= " "
        html+= link_to "Delete", admin_person_path(person), :method => :delete, :data => {:confirm => "Are you sure?"}
      end
      html
    end
    
  end


  scope :all, :default => true
  scope :with_user
  scope :with_meta_data
  scope :groups

  ###################################################
  # Transferring meta_data from one person to an other
  ###################################################

  member_action :transfer_meta_data_form

  member_action :transfer_meta_data , method: 'post'  do

    person_originator= Person.find(params[:id])
    person_receiver= Person.find(params[:id_receiver])

    ActiveRecord::Base.transaction do
      person_receiver.meta_data << 
        person_originator.meta_data.where("id not in (#{person_receiver.meta_data.select('"meta_data"."id"').to_sql})")
      person_originator.meta_data.clear
    end

    redirect_to admin_people_path
  end

end
