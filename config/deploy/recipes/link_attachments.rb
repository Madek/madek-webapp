task :link_attachments do
  # DANGER: The attachments directory is only a symlink, so no rm -r please!
  run "rm -f #{release_path}/db/media_files/production/attachments"
  run "rm -rf #{release_path}/doc/Testbilder"
  run "mkdir -p #{release_path}/db/media_files/production/"
  run "ln -s #{deploy_to}/#{shared_dir}/attachments #{release_path}/db/media_files/production/attachments"
  run "ln -sf #{deploy_to}/#{shared_dir}/previews #{release_path}/public/previews"
end
