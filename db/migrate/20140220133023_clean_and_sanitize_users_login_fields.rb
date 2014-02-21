class CleanAndSanitizeUsersLoginFields < ActiveRecord::Migration

  class User < ActiveRecord::Base
  end

  def up
    User.find_by(login: 'strebel@arch.ethz.ch').try :update_attributes, login: 'istrebel'
    User.find_by(login: 'heinz-günter.kuper').try :update_attributes, login: 'hgkuper' 
    User.find_by(login: 'markus.schönholzer').try :update_attributes, login:  'mschoenholzer' 
    User.find_by(login: 'michaelbürgi').try :update_attributes, login:  'buergi' 
    User.all.each do |user| 
      user.update_attributes login: user.login.gsub(/\@.*/, '')
    end

    change_column :users, :login, :text, limit: 40, null: false
    execute %q< ALTER TABLE users ADD CONSTRAINT users_login_simple CHECK (login ~* '^[a-z0-9\.\-\_]+$'); >

    change_column :users, :email, :string, null: false
  end

  def down
    raise "irreversible"
  end
end
