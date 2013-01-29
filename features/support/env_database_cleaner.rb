# clone the personas db before running anything
PersonasDBHelper.clone_persona_to_test_db

our_default_strategy = nil

begin
  DatabaseCleaner.strategy = our_default_strategy
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end


def is_clean? scenario
  tags =  scenario.source_tag_names
  tags.include? "@clean"
end

def uses_javascript? scenario
  tags =  scenario.source_tag_names
  not tags.select{|t| t=~ /jsbrowser|javascript|chrome|firefox/}.empty?
end


Before do |scenario|
  unless is_clean? scenario
    unless uses_javascript? scenario
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.start
    end
  end
end

After do |scenario|
  unless is_clean? scenario
    if uses_javascript? scenario
      PersonasDBHelper.clone_persona_to_test_db
    else
      DatabaseCleaner.clean
      DatabaseCleaner.strategy = our_default_strategy
    end
  end
end



