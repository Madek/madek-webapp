#!/bin/sh

echo "This does a complete reset/setup of the local dev and test environments"
echo "(Work in Progress)"

set -ex

RAILS_ENV=development bundle exec rake db:drop madek:setup:dirs db:reset madek:db:truncate madek:db:load_data FILE=db/personas.data.psql
RAILS_ENV=test bundle exec rake db:drop madek:setup:dirs db:reset madek:db:truncate madek:db:load_data FILE=db/personas.data.psql


echo -e "\n\nNow run a clean test!"
