# clone the personas db before running anything
PersonasDBHelper.clone_persona_to_test_db

our_default_strategy = nil

begin
  DatabaseCleaner.strategy = our_default_strategy
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

Before('@restore_personas_data_before') do
  PersonasDBHelper.clone_persona_to_test_db
  DatabaseCleaner.strategy = nil
end
After('@restore_personas_data_after') do
  PersonasDBHelper.clone_persona_to_test_db
  DatabaseCleaner.strategy = our_default_strategy
end

After '@dirty'  do
  PersonasDBHelper.clone_persona_to_test_db
end

Before '@transactional_dirty' do
  DatabaseCleaner.strategy = :transaction
  DatabaseCleaner.start
end

After '@transactional_dirty' do
  DatabaseCleaner.clean
  DatabaseCleaner.strategy = our_default_strategy
end



Before do
  # The path would be wrong, it might point, it might point to some developer's homedir or the
  # persona server's home dir etc.
  AppSettings.dropbox_root_dir = (Rails.root + "tmp/dropbox").to_s
  # close any alert message to not disturb following tests
  page.driver.browser.switch_to.alert.accept rescue nil 
end


