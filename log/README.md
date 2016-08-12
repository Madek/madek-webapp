# LOGGING

We only log to the console by default.
See `config/application.rb` for details.

## Development

Default level is INFO, you can set RAILS_LOG_LEVEL. Use `tee` if you want to
have the logs in a file.

## Production e.i. on the Server

RAILS_LOG_LEVEL is WARN. To change it temporarily (until the next deploy): edit
`/etc/systemd/system/madek_webapp.service`. And restart the service: `systemctl
restart madek_webapp.service`.

Use e.g. `journalctl -u madek_webapp.service` to read the logs.
