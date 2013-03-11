ActiveAdmin.register ZencoderJob, sort_order: 'created_at DESC' do
  menu :label => "ZencoderJobs", :parent => "Files"
  actions :index, :show

  filter :id
  filter :created_at
  filter :updated_at


  index do
    column :id  do |job| link_to(path = admin_zencoder_job_path(job), path)  end
    column :state
    column :media_file do |job| 
      if mf = job.media_file
        link_to(path = admin_media_file_path(mf), path)
      end
    end
    column :created_at 
    column :updated_at
  end
 
  show do |job|
    attributes_table do 
      row :id
      row :zencoder_id do
        link_to (path = "https://app.zencoder.com/jobs/#{job.zencoder_id}"), path
      end
      row :media_file
      row :state
      row :comment
      row :error do
        pre do
          job.error
        end
      end
      row :request
      row :response
      row :notification
      row :notification_url
      row :created_at
      row :updated_at
    end

  end

end

