ActiveAdmin.register MediaEntry do
  actions :index, :show

  filter :id 

  index do
    column :id do |me| link_to(me.id,admin_media_entry_path(me)) end
    column :title do |me| me.title end
    column :media_file do |me|
      if (mf = me.media_file) and path = admin_media_file_path(mf)
        link_to path, path
      end
    end
    column :owner do |me| me.user end
    column :created_at
  end

end

