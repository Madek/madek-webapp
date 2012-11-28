ActiveAdmin.register Visualization do


  index do
    column :user_id
    column :resource_identifier
    column :control_settings
    column :layout

    column do |x|
        link_to "Delete", [:admin, x], :method => :delete, :data => {:confirm => "Are you sure?"}
     end

  end



end

