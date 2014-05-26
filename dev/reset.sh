#!/bin/sh

echo "This does a complete reset/setup of the local dev and test environments"
echo "(Work in Progress)"

set -ex

for ENV in test development; do
  RAILS_ENV=$ENV bundle exec rake db:drop madek:setup:dirs db:reset madek:db:truncate madek:db:load_data FILE=db/personas.data.psql
done


echo -e "\n\nNow run a clean test!"
