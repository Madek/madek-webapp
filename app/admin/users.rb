ActiveAdmin.register User do
  belongs_to :group, optional: true
  
  menu :parent => "Subjects"

  #actions  :index, :new, :create, :edit, :update, :destroy

### FIXME active_admin issue with belongs_to/has_one:
  # https://github.com/gregbell/active_admin/issues/459
  # https://github.com/gregbell/active_admin/issues/889
=begin
  belongs_to :person, optional: true
  controller do
    def new
      @user = if params[:person_id] and person = Person.find(params[:person_id])
        person.build_user
      else
        super
      end
    end
  end
=end
  before_filter :only => :new do
    if params[:person_id] and person = Person.find(params[:person_id])
      #@user.person = person
      @user = person.build_user
    end
  end
###

  index do
    column :id
    column :login
    column :email
    column :person
    column :notes
    column :total_media_entries do |x|
      c = x.media_entries.count
      status_tag "#{c}", (c.zero? ? :warning : :ok)
    end
    column :groups do |x|
      ul
        x.groups.each do |y|
          li link_to y, edit_admin_group_path(y)
        end
    end
    column do |x|
      r = link_to "Edit", [:edit, :admin, x]
      r += " "
      r += link_to "Switch to", [:switch_to, :admin, x], :method => :post, :class => "button"
      r
    end
  end

  form do |f|
    f.inputs do
      f.input :person
      f.input :login
      f.input :email
      f.input :password
      f.input :notes
      f.input :usage_terms_accepted_at
    end
    f.actions
  end
  
  member_action :switch_to, :method => :post do
    reset_session # TODO logout_killing_session!
    self.current_user = User.find(params[:id])
    redirect_to root_path
  end

  member_action :add_membership, :method => :post do
    @user = User.find(params[:id])
    @group = Group.find(params[:group_id])
    @group.users << @user
    render :partial => "admin/groups/user", :object => @user
  end

  member_action :remove_membership, :method => :delete do
    @user = User.find(params[:id])
    @group = Group.find(params[:group_id])
    @group.users.delete(@user)
    render :nothing => true
  end

end
