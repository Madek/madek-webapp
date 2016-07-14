#!/usr/bin/env bash
bundle exec rake db:pg:terminate_connections db:drop db:create db:migrate db:seed
