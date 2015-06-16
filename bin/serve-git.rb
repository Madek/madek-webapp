#!/usr/bin/env ruby

require 'rack'

dir = Rack::Directory.new '../.git/modules/webapp'
Rack::Server.start(app: dir, Host: '0.0.0.0', Port: 3333)
