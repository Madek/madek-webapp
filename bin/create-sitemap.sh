#!/bin/sh
set -e

./bin/env/ruby-setup --quiet && \
ruby -S bundle exec rake sitemap:refresh:no_ping
