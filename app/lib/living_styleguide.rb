module LivingStyleguide

  APP_DIR = Rails.root
  SUFFIX = '.html.haml'

  def build_styleguide_tree(path_string = 'app/views/styleguide') # TODO: cache?
    # read argument path_string as 'path/path/path'
    base_dir = APP_DIR
    path_string.split('/').each { |dir| base_dir = base_dir.join dir }
    build_tree_from_static_files(base_dir)
  end

  private

  def build_tree_from_static_files(dir)
    get_subfolders_of_dir(dir)
      .map { |dirname| build_section(dirname) }
      .map { |section| get_section_details(dir, section) }
      .map { |section| build_section_element_or_info(section) }
  end

  def get_subfolders_of_dir(dir)
    Dir.entries(dir)
      .reject { |i| i.match(/\./) }     # all entries w/o a dot (sub-folders)
      .sort { |a, b| a <=> b }          # sort by name (starts with number)
  end

  def build_section(dirname)
    {
      path: dirname,
      nr: dirname.split('_')[0].to_i.to_s,
      name: dirname.split('_')[1]
    }
  end

  def get_section_details(dir, section)
    section[:elements] = Dir.entries(dir.join(section[:path]))
      .select { |i| i.match(/#{SUFFIX}$/) }
    section
  end

  def build_section_element_or_info(section)
    if section[:elements].length <= 1 # no sub-sections, just 1 info doc:
      build_info(section)
    else # has sub-sections:
      build_elements(section)
    end
  end

  def build_info(section)
    section[:subpath] = section[:elements].first
    section[:elements] = nil
    section
  end

  def build_elements(section)
    section[:elements] = section[:elements]
      .map { |element| build_element_obj(element) }
      .sort { |a, b| a[:nr] <=> b[:nr] }
    section
  end

  def build_element_obj(element)
    # last part is name, rest is numbering:
    splitted = element.split('_').select { |i| !i.empty? }
    {
      path: element,
      name: splitted.pop.chomp(SUFFIX).underscore,
      nr: splitted.join('.')
    }
  end

end
