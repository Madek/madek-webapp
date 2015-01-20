module UiHelper
  # # UI Element helpers
  #
  # - the reference for all elements is in views/styleguide
  # - in testing, the styleguide is rendered (headless) once with everything
  #   elements on 1 page to catch broken components early
  #
  # Notable patterns:
  # - elements render nothing if no data is given (less `= icon if icon`)
  # - some elements pass through all "extra" config keys to HAML/HTML
  #   (where it make sense, ie. it is closely related to a HTML tag, like icon)
  # - log warnings for things that are strange (possibly broken)
  #
  # ## API
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
  # List of Elements:

  # 1. Atoms:
  #     - are just classes, no helpers needed

  # 2. Components:
  def component(name, config = {}, &block)
    render_element('component', name, config, &block)
  end

  # 3. Combos:
  def combo(name, config = {}, &block)
    render_element('combo', name, config, &block)
  end

  # 4. Layouts:
  #     - are in views/layout, 'helpers' already built into rails
  #     - "API": use `content_for` to fill different parts of the layout

  # # misc UI helpers

  # generic partial-with-block helper
  def partial(name, locals = {}, &block)
    raise 'missing block!' unless block_given?
    render layout: name, locals: locals, &block
  end

  def link_from_item(item)
    return unless item.is_a? Hash
    if item[:href]
      { href: item[:href], target: item[:href_target] }
    end
  end

  protected

  def render_element(type, name, config = {}, &_block)
    return if name.nil?
    locals = build_locals_from_element(name, config)
    name = name_without_mod(name)
    locals[:block_content] = capture { yield } if block_given?
    render template: "_elements/#{type}s/#{name}", locals: locals
  end

  def build_locals_from_element(name, config)
    locals = {
      classes: (classes_from_element(config).push(mod_from_name(name))
                .flatten.compact),
      link: link_from_item(config)
    }
    locals = locals.merge(config) if config.is_a? Hash
    locals.delete([:mods])
    locals
  end

  def classes_from_element(config)
    # can be given as String or Hash[:mods] (String or Array)
    config ||= ''
    case
    when config.is_a?(String) then [config.split('.')]
    when config[:mods].is_a?(String) then [config[:mods].split('.')].flatten
    when config[:mods].is_a?(Enumerable) then config[:mods]
    else []
    end
  end

  def mod_from_name(name)
    supported_elements = ['icon', 'button']
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

  def name_without_mod(name)
    (name || '').split('.').first
  end
end
