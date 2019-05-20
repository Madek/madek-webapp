module Concerns
  module ControllerFavoritable
    extend ActiveSupport::Concern
    include Concerns::ResourceListParams

    def favor
      store_favorite(true)
    end

    def disfavor
      store_favorite(false)
    end

    private

    def store_favorite(value)
      resource = find_resource
      if value
        resource.favor_by(current_user)
      else
        resource.disfavor_by(current_user)
      end
      is_favored = current_user ? resource.favored?(current_user) : false
      result = { isFavored: is_favored }
      if request.accept == 'application/json'
        respond_to do |format|
          format.json { render json: result, status: :created }
        end
      else
        name = controller_name.singularize
        action = value ? 'favored' : 'disfavored'
        i18n_key = "#{name}_was_" + action
        message = I18n.t(i18n_key.to_sym)
        redirect_back fallback_location: proc { send(name + '_path', resource) },
                      flash: { success: message }
      end
    end

  end
end
