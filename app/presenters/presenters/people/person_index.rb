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
        fragments.join(' - ') unless fragments.empty?
      end
    end
  end
end
