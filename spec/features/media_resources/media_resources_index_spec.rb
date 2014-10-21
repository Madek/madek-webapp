require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

feature 'MediaResource' do

  scenario 'index Resources plainly and check overlays',
           browser: :firefox do

    # As Normin, I go to 'my dashboard'
    @current_user = sign_in_as 'normin'
    visit my_dashboard_path

    # I can see a Media Resources Container, containing some resources
    container = find('.ui-resources.grid.active')
    expect(container).to be
    resources = container.all('li.ui-resource')
    expect(resources.length).to be > 0

    # There is a Media Set, with a working overlay on top and bottom
    media_set = container.find('[data-type="media-set"]')
    check_hover_overlay(media_set, 'top')
    check_hover_overlay(media_set, 'bottom')

    # There is a Media Entry, with a working overlay on top
    media_entry = container.find('[data-type="media-entry"]')
    check_hover_overlay(media_entry, 'top')
  end

  scenario 'index Resources in List and check overlays',
           browser: :firefox do

    # As Normin, I go to 'my media resources'
    @current_user = sign_in_as 'normin'
    visit my_media_resources_path

    # I can see a Media Resources List Container
    container = find('#ui-resources-list-container')
    expect(container).to be

    # and a List inside, containing some resources on first page
    list = container.find('#ui-resources-list')
    resources = list.find('ul.ui-resources-page-items').all('li.ui-resource')
    expect(resources.length).to be > 0

    # There is a Media Set, with a working overlay on top and bottom
    media_set = list.all('[data-type="media-set"]').last
    check_hover_overlay(media_set, 'top')
    check_hover_overlay(media_set, 'bottom')

    # There is a Media Entry, with a working overlay on top
    media_entry = list.all('[data-type="media-entry"]').last
    check_hover_overlay(media_entry, 'top')
  end

  # Helpers:
  def check_hover_overlay(resource, placement = 'top')
    level = placement == 'top' ? 'up' : 'down'
    heading_str = placement == 'top' ? 'Übergeordnete Sets' : 'Set enthält'
    # Hover over resource, give time to render
    move_mouse_over resource
    sleep 1
    # Overlay is visible,
    overlay = resource.find(".ui-thumbnail-level-#{level}-items", visible: true)
    expect(overlay).to be
    # and has the correct (dynamically rendered) heading inside
    # binding.pry
    heading = overlay.find('h3.ui-thumbnail-level-notes').text
    expect(heading).to eq heading_str
  end

end
