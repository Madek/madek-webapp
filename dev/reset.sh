#!/bin/sh

echo "This does a complete reset/setup of the local dev and test environments"
echo "If it fails, you most likely have open connections to the db."
echo "(Work in Progress)"
sleep 5

set -ex

for ENV in test development; do
  RAILS_ENV=$ENV bundle exec rake madek:setup:dirs db:drop db:reset db:migrate madek:db:truncate madek:db:load_data FILE=db/personas.data.psql
done


echo "Now run a clean test!"
