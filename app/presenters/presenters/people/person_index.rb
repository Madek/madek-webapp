module Presenters
  module People
    class PersonIndex < PersonCommon
      def initialize(app_resource, count = nil)
        super(app_resource)
      end

      delegate_to_app_resource :first_name, :last_name, :pseudonym

      def info
        fields = AppSetting.first.person_info_fields
        fragments = []
        if fields.include?('institutional_id') && @app_resource.institutional_id
          fragments << "#{@app_resource.institution} #{@app_resource.institutional_id}"
        end
        if fields.include?('identification_info') && @app_resource.identification_info
          fragments << @app_resource.identification_info
        end
        if fields.include?('institutional_directory_infos') && @app_resource.institutional_directory_infos.any?
          fragments += @app_resource.institutional_directory_infos
        end
        fragments
      end
    end
  end
end
