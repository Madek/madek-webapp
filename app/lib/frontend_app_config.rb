# shared (per-instance) app config. Frontend/JS needs this and it can't be bundled!
# - injected into server renderer (`React::ServerRendering::SprocketsRenderer`)
# - injected into frontend (`HTML <head>`)
class FrontendAppConfig

  def self.to_js # NOTE: this generates JavaScript to be included as-is (global!)
    "Object.freeze(APP_CONFIG = #{JSON.generate(self.app_config)})"
  end

  def self.app_config
    @app_config_memo ||= {
      relativeUrlRoot: \
        Rails.application.config.action_controller.relative_url_root,
      assetsPath: Rails.application.config.assets.prefix
    }
  end

end
