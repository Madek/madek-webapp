module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/, /the dashboard/
      root_path

    when /the media entries/
      media_resources_path
      
    when /the upload edit/
      edit_upload_path
      
    when /^the wiki$/
      '/wiki'

    when /the "(.*)" wiki/
      '/wiki/'+ $1

    when /the wiki edit page/
      '/wiki/edit?path='
      
    when /my sets page/
      media_resources_path(:user_id => @current_user, :type => "media_sets", :top_level => true)

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
