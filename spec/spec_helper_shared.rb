# A few global functions shared between all rspec tests.

# the exact route a keyword path is redirected to (filter entries by it)
def filter_by_keyword_path(keyword)
  '/entries?' + {
    list: {
      filter: JSON.generate(
        meta_data: [{
          key: keyword.meta_key.id,
          value: keyword.id,
          type: 'MetaDatum::Keywords' }]),
      show_filter: true }
  }.to_query
end
