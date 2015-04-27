# NOTE: this is directy used in the "polybox" decorator, because
# - its only needed there
# - there is always at most 2 polybox per view
# If that should ever change (e.g. pagination is needed per-element),
# instantiate this per-element.

Kaminari.configure do |config|
  config.default_per_page = 12
  # config.max_per_page = nil
  # config.window = 4
  # config.outer_window = 0
  # config.left = 0
  # config.right = 0
  # config.page_method_name = :page
  # config.param_name = :page
end
