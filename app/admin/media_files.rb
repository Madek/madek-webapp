ActiveAdmin.register MediaFile do
  menu :label => "MediaFiles", :parent => "Files"

  actions :index, :show

  filter :id
  filter :media_type, as: :check_boxes, :collection => proc{ MediaFile.select(:media_type).uniq.map(&:media_type)}
  filter :created_at
  filter :updated_at

  member_action :reencode, method: :post do
    begin 
      @media_file = MediaFile.find params[:id]
      @media_file.previews.destroy_all
      ZencoderJob.create(media_file: @media_file).submit
      redirect_to admin_media_file_path(@media_file), flash: {success: "The Zencoder.job has been submitted"}
    rescue => e 
      redirect_to admin_media_file_path(@media_file), flash: {error: e}
    end
  end

  member_action :recreate_thumbnails, method: :post do
    begin 
      @media_file = MediaFile.find params[:id]
      @media_file.previews.destroy_all
      @media_file.make_thumbnails
      redirect_to admin_media_file_path(@media_file), flash: {success: "The thumbnails have been recreated"}
    rescue => e 
      redirect_to admin_media_file_path(@media_file), flash: {error: e}
    end
  end


  index do
    column :id  do |media_file| link_to(media_file.id, admin_media_file_path(media_file)) end
    column :media_entry do |mf| 
      if me = mf.media_entry
        link_to me.id, admin_media_entry_path(me)
      end
    end
    column :media_type 
    column :filename
    column :created_at 
  end
 
  show do |media_file|
    attributes_table do 
      row :id
      row :media_entry do
        if media_file.media_entry
          span link_to(admin_media_entry_path(media_file.media_entry), admin_media_entry_path(media_file.media_entry)) 
          span ", "
          span link_to(media_entry_path(media_file.media_entry), media_entry_path(media_file.media_entry))
        end
      end
      row :media_entry_owner do
        if media_file.media_entry
          media_file.media_entry.user
        end
      end
      row :content_type
      row :media_type
      row :filename
      row :meta_data
      row :created_at
      row :updated_at
    end

    panel "Previews" do
      if media_file.content_type.match /image|pdf/ and media_file.media_entry
        div do
          link_to "Recreate Thumbnails", recreate_thumbnails_admin_media_file_path(media_file), \
            class: 'button', method: 'post'
        end
      end

      table_for media_file.previews, class: "previews" do
        column "Preview" do |preview|
          link_to (path= admin_preview_path(preview)), path
        end
        column :content_type
        column :thumbnail
        column :created_at
      end
    end


    if ['video','audio'].include? media_file.media_type
      panel "Zencoder Jobs" do
        div do
          link_to "Reencode", reencode_admin_media_file_path(media_file), \
            class: 'button', method: 'post', data: {confirm: "Let previes reencode by zencoder.com? This action is liable to pay costs."}
        end

        table_for media_file.zencoder_jobs, class:  "zencoder-jobs" do
          column "job" do |job|
            link_to (path= admin_zencoder_job_path(job)), path
          end
          column :state
          column :created_at
        end
      end
    end

  end



end

