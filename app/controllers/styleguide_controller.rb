class StyleguideController < ApplicationController
  layout 'styleguide'

  include LivingStyleguide # builds tree from static files (table of contents)
  include ResourceListParams
  helper_method :resource_list_params

  before_action do
    skip_authorization
    @sections = build_styleguide_tree # from LivingStyleguide module
  end

  def index
  end

  def show
    @resource_list_params = resource_list_by_type_param
    @section = find_section_by_param(@sections, :section)
  end

  def element # single element view, mostly needed for testing
    @section = find_section_by_param(@sections, :section)
    return if @section[:elements].nil?
    @element = find_element_by_param(@section[:elements], :element)
  end

  private

  def find_section_by_param(sections, param)
    sections.find { |s| s[:name] == params[param] }
  end

  def find_element_by_param(elements, param)
    elements.find { |e| e[:name] == params[param] }
  end

end
