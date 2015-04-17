module Admin::VocabularyPermissionPathsHelper
  def path_to_vocabulary_permission_form(object)
    class_name_underscored = object.class.base_class.name.underscore
    request_params = {
      vocabulary_id: session[:vocabulary_id],
      "#{class_name_underscored}_id" => object.id
    }
    action_prefix =
      if session[:is_persisted] == 'true'
        request_params.merge!(id: session[:permission_id])
        :edit
      else
        :new
      end

    method_name = "#{action_prefix}_admin_vocabulary_" \
                  "vocabulary_#{class_name_underscored}_permission_path"

    send(method_name, request_params)
  end
end
