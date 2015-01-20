class StyleguideController < ActionController::Base
  layout 'styleguide'

  include LivingStyleguide # builds tree from static files (table of contents)

  before_action :set_sections

  def index
  end

  def show
    @section = find_section_by_param(@sections, :section)
  end

  def element # single element view, mostly needed for testing
    @section = find_section_by_param(@sections, :section)
    return if @section[:elements].nil?
    @element = find_element_by_param(@section[:elements], :element)
  end

  private

  def set_sections
    @sections = build_styleguide_tree
  end

  # helpers:
  def find_section_by_param(sections, param)
    sections.find { |s| s[:name] == params[param] }
  end

  def find_element_by_param(elements, param)
    elements.find { |e| e[:name] == params[param] }
  end

end
