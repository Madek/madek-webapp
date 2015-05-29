class UpgradeAppSettingsForV3 < ActiveRecord::Migration
  # TODO: [#95853544] (fill in fields, uncomment 'null: false' here)
  def change
    rename_column :app_settings, :title, :site_title
    change_column_default :app_settings, :site_title, 'Media Archive'
    # change_column_null :app_settings, :site_title, false

    rename_column :app_settings, :brand, :brand_text
    change_column_default :app_settings, :brand_text, 'ACME, Inc.'
    # change_column_null :app_settings, :brand_text, false

    rename_column :app_settings, :logo_url, :brand_logo_url

    change_column_default :app_settings, :welcome_title,
      'Powerful Global Information System'
    # change_column_null :app_settings, :welcome_title, false

    change_column_default :app_settings, :welcome_subtitle,
      '“Academic information should be freely available to anyone” — Tim Berners-Lee'
    # change_column_null :app_settings, :welcome_subtitle, false

    rename_column :app_settings, :footer_links, :sitemap
    # old JSON needs to be tranformed like this:
    # JSON.parse('{"example": "http://example.com"}').map {|k,v| {k=>v} }.to_json
    change_column :app_settings, :sitemap,
                  'jsonb USING CAST(sitemap AS jsonb)',
                  default: '
                    [
                      { "Medienarchiv ZHdK": "http://medienarchiv.zhdk.ch" },
                      { "Madek Project on Github": "https://github.com/Madek" }
                    ]
                  ' # , null: false
  end
end
