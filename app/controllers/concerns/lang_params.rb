module Concerns
  module LangParams
    extend ActiveSupport::Concern

    # i18n setup

    included do
      before_action :set_locale_for_app
    end

    def set_locale_for_app
      return if @set_locale_for_app_done == true # memo
      Rails.configuration.i18n.default_locale = AppSetting.default_locale
      Rails.configuration.i18n.available_locales = AppSetting.available_locales
      # NOTE: try `request.query_parameters` in case of
      #       POST actions with body params BUT lang in URL query
      I18n.locale = params[:lang] || request.query_parameters['lang'] || I18n.default_locale
      # presenters need to know about set default_url_options from controller
      Presenter.instance_eval do
        def default_url_options(options = {})
          return options if I18n.locale == I18n.default_locale
          { lang: I18n.locale }.merge(options)
        end
      end
      @set_locale_for_app_done = true
    end

    # for all generated URLs, set language param if it's not the default
    def default_url_options(options = {})
      return options if I18n.locale == I18n.default_locale
      { lang: I18n.locale }.merge(options)
    end

  end
end
