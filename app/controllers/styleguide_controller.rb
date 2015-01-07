class StyleguideController < ActionController::Base
  layout 'styleguide'

  def index
    @sections = build_content
  end

  def show
    @sections = build_content
    @section = find_section_by_param(@sections, :section)
  end

  def element # single element view, mostly needed for testing
    @sections = build_content
    @section = find_section_by_param @sections
    return if @section.nil? || @section[:elements].nil? # no info pages needed
    @element = @section[:elements].find { |e| e[:name] == params[:element] }
  end

  private

  def build_content(path_string = 'views/styleguide') # TODO: cache?
    # config
    app_dir = Rails.root.join('app')
    suffix = '.html.haml'

    # read argument path_string as 'path/path/path'
    base_dir = app_dir
    path_string.split('/').each { |dir| base_dir = base_dir.join dir }

    build_tree_from_static_files(base_dir, suffix)
  end

  # helpers:
  def find_section_by_param(sections, param)
    sections.find { |s| s[:name] == params[param] }
  end

  def build_tree_from_static_files(dir, suffix)
    sections = section_per_directory dir
    elements_per_section dir, suffix, sections
    sections
  end

  def section_per_directory(dir)
    # TODO: File.directory?(".")
    Dir.entries(dir)                    # all files in dir
      .reject { |i| i.match(/\./) }     # all entries without a dot (folders)
      .sort { |a, b| a <=> b }          # sort by name (starts with number)
      .map do |section|                 # build object
        {
          path: section,
          nr: section.split('_')[0].to_i.to_s,
          name: section.split('_')[1]
        }
      end
  end

  def elements_per_section(dir, suffix, sections)
    sections.map do |section|
      elements = \
        Dir.entries(dir.join(section[:path]))
          .select { |i| i.match(/#{suffix}$/) }

      if elements.length <= 1 # no sub-sections, just 1 info doc:
        section[:subpath] = elements.first
        elements = nil
      else # has sub-sections:
        elements.map! do |element|
          # last part is name, rest is numbering
          get_path_nr_name_hash(element, suffix)
        end
        elements.sort! { |a, b| a[:nr] <=> b[:nr] }
      end
      section[:elements] = elements
      section
    end
  end

  private

  def get_path_nr_name_hash(element, suffix)
    strings = element.split('_').select { |i| !i.empty? }
    name = strings.pop
    number = strings.join('.')
    {
      path: element,
      nr: number,
      name: name.chomp(suffix).underscore
    }
  end

end
