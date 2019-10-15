# to be configured via environment variables in the systemd-service-file,
# provided default values are for development.
# example:
# [Service]
# Environment=RAILS_ENV=production
# Environment=MADEK_MAX_WORKERS=2
# Environment=MADEK_MAX_THREADS=5

workers Integer(ENV['MADEK_MAX_WORKERS']) if ENV.fetch('MADEK_MAX_WORKERS', false)
threads_count = Integer(ENV['MADEK_MAX_THREADS'] || 4)
threads threads_count, threads_count

preload_app!

environment ENV['RAILS_ENV'] || 'development'

on_worker_boot do
  ActiveRecord::Base.establish_connection
end
