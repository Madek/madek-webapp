class StyleguideController < ActionController::Base
  layout 'styleguide'

  include LivingStyleguide # builds tree from static files (table of contents)

  def index
    @sections = build_styleguide_tree
  end

  def show
    @sections = build_styleguide_tree
    @section = find_section_by_param(@sections, :section)
  end

  def element # single element view, mostly needed for testing
    @sections = build_styleguide_tree
    @section = find_section_by_param(@sections, :section)
    return if @section.nil? || @section[:elements].nil? # no info pages needed
    @element = @section[:elements].find { |e| e[:name] == params[:element] }
  end

  private

  # helpers:
  def find_section_by_param(sections, param)
    sections.find { |s| s[:name] == params[param] }
  end

end
