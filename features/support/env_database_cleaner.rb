# How to clean your database when transactions are turned off. See
# http://github.com/bmabey/database_cleaner for more info.
require 'database_cleaner'

DatabaseCleaner.strategy = :truncation, {:except => %w[meta_keys meta_contexts meta_terms meta_keys_meta_terms meta_key_definitions meta_departments usage_terms]}
