require 'rails_helper'
require 'spec_helper_feature_shared'

feature 'Visualization / Graph' do
  background do
    @current_user = sign_in_as 'Normin'
  end

  scenario 'Calculating graph on the media set view', browser: :firefox do
    open_owned_media_set_having_children_and_parents
    find('a', text: 'Weitere Aktionen').click

    anchor = find('a', text: 'Zusammenhänge anzeigen')
    target_url = anchor[:href]
    anchor.click

    expect_relations_for_media_resource(target_url)
  end

  scenario 'Calculating graph on the media entry view', browser: :firefox do
    open_owned_media_entry_which_is_child_of_accessible_set
    click_link 'Weitere Aktionen'

    anchor = find('a', text: 'Zusammenhänge anzeigen')
    target_url = anchor[:href]
    anchor.click

    expect_relations_for_media_resource(target_url)
  end

  scenario 'Browser switcher', browser: :firefox do
    clean_up_visualizations
    expect_browser
    visit '/visualization/my_media_resources#test_noupdate_positions'
    expect_running_visualization_test
    expect(page).to have_css('#loading')
    wait_for_graph
    expect(page).not_to have_content 'Test failed'
  end

  scenario 'Popup for a set', browser: :firefox do
    visit '/visualization/my_media_resources'
    inspect_media_set_more_closely
    expect_popup
    expect_title_for_resource
    expect_permission_icon_for_resource
    expect_favorite_status_for_resource
    expect_number_of_children
    expect_links_to_resource_descendants_and_components
  end

  scenario 'Popup for a media entry', browser: :firefox do
    visit '/visualization/my_media_resources'
    inspect_media_entry_more_closely
    expect_popup
    expect_title_for_resource
    expect_permission_icon_for_resource
    expect_favorite_status_for_resource
    expect_no_number_of_children_and_parents
    expect_links_to_resource_components
    expect_no_links_to_resource_descendants
  end

  scenario 'Origin highlight', browser: :firefox do
    visualize_descendants_of_media_set
    expect_origin_set_highlighted
    expect_graph_title_to_include_title_of_media_set

    visualize_component_of_media_entry
    expect_origin_entry_highlighted
    expect_graph_title_to_include_title_of_media_entry
  end

  scenario 'Default labels', browser: :firefox do
    clean_up_visualizations
    visit '/visualization/my_media_resources'
    expect_selected_label_option 'sets_having_descendants'
    expect_labels_of_sets_having_children
  end

  scenario 'Selecting option all labels', browser: :firefox do
    clean_up_visualizations
    visit '/visualization/my_media_resources'
    select_label_option 'alle'
    expect_all_labels
  end

  scenario 'Selecting non labels', browser: :firefox do
    clean_up_visualizations
    visit '/visualization/my_media_resources'
    select_label_option 'keine'
    expect_no_labels
  end

  def clean_up_visualizations
    Visualization.delete_all
  end

  def expect_all_labels
    all('.node').each do |el|
      expect(el).to have_css('.node_label_title')
    end
  end

  def expect_browser
    expect(page.evaluate_script('BrowserDetection.name()')).not_to eq('Chrome')
    expect(page.evaluate_script('BrowserDetection.name()')).not_to eq('Safari')
  end

  def expect_favorite_status_for_resource
    expect(@popup).to have_css('.favorite_info i', visible: false)
  end

  def expect_graph_title_to_include_title_of_media_entry
    expect(find('.app')).to have_content(@media_entry.title)
  end

  def expect_graph_title_to_include_title_of_media_set
    expect(find('.app')).to have_content(@media_set.title)
  end

  def expect_labels_of_sets_having_children
    # by default there are labels of the sets that have children in the current visualization
    all(".node:not([data-size='0'])").each do |el|
      expect(el).to have_css('.node_label_title')
    end
    all(".node[data-size='0']").each do |el|
      expect(page).not_to have_selector(".node##{el['id']} .node_label")
    end
  end

  def expect_links_to_resource_components
    expect(@popup).to have_css('a#link_for_component_with')
    expect(@popup).to have_css('a#link_for_my_component_with')
  end

  def expect_links_to_resource_descendants_and_components
    expect(@popup).to have_css('a#link_for_resource')
    expect(@popup).to have_css('a#link_for_component_with')
    expect(@popup).to have_css('a#link_for_my_component_with')
    expect(@popup).to have_css('a#link_for_my_descendants_of')
    expect(@popup).to have_css('a#link_for_descendants_of')
  end

  def expect_no_labels
    all('.node').each do |el|
      expect(page).not_to have_selector(".node##{el['id']} .node_label")
    end
  end

  def expect_no_links_to_resource_descendants
    expect(@popup).not_to have_css('a#link_for_my_descendants_of')
    expect(@popup).not_to have_css('a#link_for_descendants_of')
  end

  def expect_no_number_of_children_and_parents
    expect(@popup.all('.media_entry.icon', visible: false).size).to eq(0)
    expect(@popup.all('.media_set.icon', visible: false).size).to eq(0)
  end

  def expect_number_of_children
    expect(@popup.find('.n_media_sets').text.to_i).
      to eq(@media_resource.child_media_resources.media_sets.size)
    expect(@popup.find('.n_media_entries').text.to_i).
      to eq(@media_resource.child_media_resources.media_entries.size)
  end

  def expect_origin_entry_highlighted
    expect( all("#resource-#{@media_entry.id} .origin").size ).to be > 0
  end

  def expect_origin_set_highlighted
    expect( all("#resource-#{@media_set.id} .origin").size ).to be > 0
  end

  def expect_permission_icon_for_resource
    expect(@popup).to have_css('.ui-thumbnail-privacy i')
  end

  def expect_popup
    expect(page).to have_css('.ui-tooltip-content')
    @popup = find('.ui-tooltip-content')
  end

  def expect_relations_for_media_resource(target_url)
    nodes =
      if @media_set
        MediaResource.connected_resources(@media_set, @current_user.media_resources)
      elsif @media_entry
        MediaResource.connected_resources(@media_entry, @current_user.media_resources)
      else
        MediaResource.filter(@current_user, @filter)
      end
    page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
    expect(current_url).to match(target_url)
    env = Rack::MockRequest.env_for(current_url)
    request = Rack::Request.new(env)
    visit url_for(
      Rails.application.routes.recognize_path(current_url).
        merge(insert_to_dom: true, only_path: true).merge(request.params)
    )

    graph_data = find('#graph-data', visible: false)
    # nodes
    node_data = JSON.parse(graph_data[:"data-nodes"])
    expect( node_data.map { |node| node['id'] }.sort ).to eq( nodes.map(&:id).sort )
    nodes.each { |node| expect(page).to have_css(".node[data-resource-id='#{node.id}']") }
    # arcs
    arcs = MediaResourceArc.connecting(nodes)
    arc_data = JSON.parse(graph_data[:"data-arcs"])
    arcs.each do |arc|
      expect(
        arc_data.any? { |a| a['child_id'] == arc.child_id && a['parent_id'] == arc.parent_id }
      ).to be true
    end
    arcs.each { |arc| expect(page).to have_css(".arc[parent_id='#{arc.parent_id}'][child_id='#{arc.child_id}']") }
  end

  def expect_running_visualization_test
    find('#test_noupdate_positions_running', visible: false)
  end

  def expect_selected_label_option(option)
    expect(find("form select.show_labels option[value='#{option}']", visible: false)).to be_selected
  end

  def expect_title_for_resource
    expect(@popup.find('h2').text).to eq(@media_resource.title)
  end

  def find_owned_media_set_having_children_and_parents
    @media_set = @current_user.media_sets.
      where(%{ EXISTS (SELECT true FROM media_resource_arcs WHERE child_id = media_resources.id) }).
      where(%{ EXISTS (SELECT true FROM media_resource_arcs WHERE parent_id = media_resources.id) }).
      first
  end

  def inspect_media_entry_more_closely
    @media_resource = @current_user.media_entries.first
    page.execute_script("Test.Visualization.mouse_enter_set('#{@media_resource.id}')")
  end

  def inspect_media_set_more_closely
    @media_resource = @current_user.media_sets.first
    page.execute_script("Test.Visualization.mouse_enter_set('#{@media_resource.id}')")
  end

  def open_owned_media_entry_which_is_child_of_accessible_set
    @media_entry = @current_user.media_entries.detect { |media_entry|
      media_entry.parents.accessible_by_user(@current_user, :edit).size > 0
    }
    visit media_resource_path(@media_entry)
  end

  def open_owned_media_set_having_children_and_parents
    find_owned_media_set_having_children_and_parents
    visit media_resource_path(@media_set)
  end

  def select_label_option(value)
    find('a.primary-button').click
    select value, from: 'show_labels'
  end

  def visualize_component_of_media_entry
    @media_entry = @current_user.media_resources.
      where(%[ EXISTS (SELECT true FROM media_resource_arcs WHERE child_id = media_resources.id) ]).
      first
    visit "/visualization/component_with/#{@media_entry.id}"
  end

  def visualize_descendants_of_media_set
    find_owned_media_set_having_children_and_parents
    visit "/visualization/descendants_of/#{@media_set.id}"
  end

  def wait_for_graph
    Timeout.timeout(15) do
      loop do
        break if page.has_no_css?('#loading')
      end
    end
  end
end
