class StyleguideController < ApplicationController
  layout 'styleguide'

  include LivingStyleguide # builds tree from static files (table of contents)
  include Concerns::ResourceListParams
  helper_method :resource_list_params

  before_action do
    @sections = build_styleguide_tree # from LivingStyleguide module
  end

  def index
  end

  def show
    @resource_list_params = resource_list_params
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
