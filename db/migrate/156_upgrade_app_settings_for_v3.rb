class UpgradeAppSettingsForV3 < ActiveRecord::Migration
  class ::MigrationAppSetting < ActiveRecord::Base
    self.table_name = 'app_settings'
  end

  def change
    change_column_default :app_settings, :id, 0

    app_setting = (AppSetting.first or AppSetting.create)

    rename_column :app_settings, :title, :site_title
    site_title_default = 'Media Archive'
    change_column_default :app_settings, :site_title, site_title_default
    AppSetting.reset_column_information
    unless app_setting.reload.site_title
      app_setting.update_attribute :site_title, site_title_default
    end
    change_column_null :app_settings, :site_title, false

    rename_column :app_settings, :brand, :brand_text
    brand_text_default = 'ACME, Inc.'
    change_column_default :app_settings, :brand_text, brand_text_default
    AppSetting.reset_column_information
    unless app_setting.reload.brand_text
      app_setting.update_attribute :brand_text, brand_text_default
    end
    change_column_null :app_settings, :brand_text, false

    rename_column :app_settings, :logo_url, :brand_logo_url

    welcome_title_default = 'Powerful Global Information System'
    change_column_default :app_settings, :welcome_title, welcome_title_default
    AppSetting.reset_column_information
    unless app_setting.reload.welcome_title
      app_setting.update_attribute :welcome_title, welcome_title_default
    end
    change_column_null :app_settings, :welcome_title, false

    rename_column :app_settings, :welcome_subtitle, :welcome_text
    welcome_text_default = \
      '**“Academic information should be freely available to anyone”** — Tim Berners-Lee'
    change_column_default :app_settings, :welcome_text, welcome_text_default
    AppSetting.reset_column_information
    unless app_setting.reload.welcome_text
      app_setting.update_attribute :welcome_text, welcome_text_default
    end
    change_column_null :app_settings, :welcome_text, false

    rename_column :app_settings, :footer_links, :sitemap
    AppSetting.reset_column_information
    app_setting.reload

    sitemap_default = '[{ "Medienarchiv ZHdK": "http://medienarchiv.zhdk.ch" }, '\
                       '{ "Madek Project on Github": "https://github.com/Madek" }]'

    # old JSON needs to be tranformed like this:
    old_value = app_setting.sitemap
    old_json_value = JSON.parse(old_value) if old_value.present?

    # either the transformed JSON or the default:
    new_json_value = if old_json_value
      old_json_value.map {|k,v| {k=>v} }.to_json
    else
      sitemap_default
    end

    app_setting.update_attribute :sitemap, new_json_value

    change_column :app_settings, :sitemap,
                  'jsonb USING CAST(sitemap AS jsonb)',
                  default: sitemap_default,
                  null: false

  end
end
