require('json')
require('simplecov')

# init_simple_cov
SimpleCov.command_name 'Unit Tests'
res = SimpleCov::Result.new JSON.parse File.read('coverage/.resultset.json')

formatter = SimpleCov::Formatter::HTMLFormatter.new
formatter.config({ inline_assets: true })
formatter.format res
