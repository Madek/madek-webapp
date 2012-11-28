ActiveAdmin.register Group do
  menu :parent => "Subjects"

  actions  :index, :new, :create, :edit, :update, :destroy

  scope :all, :default => true
  scope :groups do |records|
    records.where(:type => "Group")
  end
  scope :departments

  index do
    column :name
    column :type
    column :users do |x|
      c = x.users.count
      status_tag "#{c}", (c.zero? ? :warning : :ok)
    end
    column do |x|
      r = raw("")
      unless x.is_a? MetaDepartment
        r += link_to "Edit", edit_admin_group_path(x)
      end
      if x.users.empty?
        r += " "
        r += link_to "Delete", admin_group_path(x), :method => :delete, :data => {:confirm => "Are you sure?"}
      end
      r
    end
  end

  form :partial => "form"
    
end
