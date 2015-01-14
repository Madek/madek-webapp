module LivingStyleguide

  def build_styleguide_tree(path_string = 'app/views/styleguide') # TODO: cache?
    # config
    app_dir = Rails.root
    suffix = '.html.haml'

    # read argument path_string as 'path/path/path'
    base_dir = app_dir
    path_string.split('/').each { |dir| base_dir = base_dir.join dir }

    build_tree_from_static_files(base_dir, suffix)
  end

  private

  def build_tree_from_static_files(dir, suffix)
    sections = section_per_directory dir
    build_elements_per_section dir, suffix, sections
    sections
  end

  def section_per_directory(dir)
    # TODO: File.directory?(".") for checking if it's a dirs
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

  def build_elements_per_section(dir, suffix, sections)
    sections.map do |section|
      elements = Dir.entries(dir.join(section[:path]))
        .select { |i| i.match(/#{suffix}$/) }
      if elements.length <= 1 # no sub-sections, just 1 info doc:
        section[:subpath] = elements.first
        elements = nil
      else # has sub-sections:
        elements.map! { | element | build_element_obj(element, suffix) }
        elements.sort! { |a, b| a[:nr] <=> b[:nr] }
      end
      section[:elements] = elements
      section
    end
  end

  def build_element_obj(element, suffix)
    # last part is name, rest is numbering:
    strings = element.split('_').select { |i| !i.empty? }
    name = strings.pop
    number = strings.join('.')
    { path: element,
      nr: number,
      name: name.chomp(suffix).underscore }
  end

end
