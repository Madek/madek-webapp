
module UiHelper
  # UI Element helpers
  #
  #
  # API:
  #
  # ```rb
  # element('name', 'class')
  # element('name', 'class.another-class')
  # element('name', { mods: ['class', 'another-class'], <more data> })
  # ```
  #
  # <more data> (common options):
  # - `mods` - elements modificator (class names), see styleguide for options
  # - `link` - special shortcut key for links, supports icons etc.
  #
  # Elements:

  # 1. "Atoms": HAML

  # 2. Components:
  def component(name, config = {}, &block)
    render_element('component', name, config, &block)
  end

  # 3. Combos:
  def combo(name, config = {}, &block)
    render_element('combo', name, config, &block)
  end

  # 4. Decorators:
  def deco(name, config = {})
    locals = build_locals_from_element(name, config)
    name = name_without_mods(name)
    template_path = "decorators/#{name}"

    render template: template_path, locals: locals
  end

  # 5. Layouts: views/layout

  # # misc UI helpers

  # generic partial-with-block helper
  def render_partial(name, locals = {}, &block)
    render layout: name, locals: locals, &block if block_given?
  end

  def link_from_item(item)
    return unless item.is_a? Hash
    if item[:href]
      { href: item[:href], target: item[:href_target] }
    end
  end

  protected

  def render_element(type, name, config, &_block)
    return if name.nil?
    locals = build_locals_from_element(name, config)
    name = name_without_mods(name)
    locals[:list] = build_list(locals[:list])
    locals[:block_content] = capture { yield } if block_given?
    template_path = "#{type}s/#{name}"

    read_from_cache_or_render template_path: template_path,
                              locals: locals
  end

  def read_from_cache_or_render(template_locals)
    Rails.cache.fetch template_locals.hash do
      render template: template_locals[:template_path],
             locals: template_locals[:locals]
    end
  end

  def build_locals_from_element(name, config)
    locals = {
      classes: (classes_from_element(config).push(mods_from_name(name)))
                .flatten.compact,
      link: link_from_item(config),
      interactive: config.try(:interactive) || false,
      block_content: nil
    }
    if config.is_a? Hash
      locals.merge(config.except([:mods]))
    else
      locals
    end
  end

  def classes_from_element(config = {})
    # can be given as String or Hash[:mods] (String or Array)
    return [config.split('.')] if config.is_a?(String)
    return [] unless config.is_a?(Hash) && config[:mods]
    case
    when config[:mods].is_a?(String) then [config[:mods].split('.')].flatten
    when config[:mods].is_a?(Enumerable) then config[:mods]
    else []
    end
  end

  def mods_from_name(name)
    supported_elements = ['icon', 'button', 'tag-cloud']
    mods = name.split('.')
    element = mods.shift(1).first
    return unless mods
    classes = supported_elements.map do |supported|
      if element == supported
        mods.map { |mod| "#{element}-#{mod}" }
      end
    end
    classes.flatten.compact
  end

  def name_without_mods(name)
    (name || '').split('.').first
  end

  def build_list(list = [])
    # only transform Hashes
    return list unless list.is_a?(Hash)
    Hash[list.map { |id, itm| [id, build_locals_from_element("#{id}", itm)] }]
  end
end
