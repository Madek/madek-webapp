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
  def deco(name, config = {}, &_block)
    locals = build_locals_from_element(name, config)
    locals[:block_content] = capture_haml { yield } if block_given?
    name = name_without_mods(name)
    render(template: "decorators/#{name}", locals: locals)
  end

  # 5. Layouts: views/layout

  # # misc UI helpers

  # React Components (proxy to view helper from `react_rails` gem w/ config)
  def react(name, props = {}, opts = {})
    defaults = { prerender: !params.permit(:___norender).present? }
    opts = defaults.merge(opts)
    maybe_presenter = props[:get]
    if maybe_presenter.is_a?(Presenter)
      # NOTE: all of the queries happen here:
      props = props.merge(get: maybe_presenter.dump)
    end
    # inject route + auth token for all "top-level" components (aka Views)
    props = props.merge(
      authToken: form_authenticity_token, for_url: request.original_fullpath)
    react_component("UI.#{name}", props, opts)
  end

  # generic partial-with-block helper
  def render_partial(name, locals = {}, &block)
    render layout: name, locals: locals, &block if block_given?
  end

  def link_from_item(config) # normalize `link` option
    return unless config.is_a?(Hash)
    link = config[:link]
    case
    when link.is_a?(String) # support string shortcut
      { href: link }
    when link.is_a?(Hash) && link[:href].is_a?(String) # full form, just validate
      link
    when config[:href] # also support normal (haml) usage
      { href: config[:href], target: config[:href_target] }
    else
      false
    end
  end

  protected

  def render_element(type, name, config, &_block)
    return if name.nil?
    locals = build_locals_from_element(name, config)
    name = name_without_mods(name)
    locals[:list] = build_list(locals[:list])
    locals[:block_content] = capture_haml { yield } if block_given?
    template_path = "#{type}s/#{name}"
    render template: template_path, locals: locals
  end

  def build_locals_from_element(name, config)
    locals = {
      classes: classes_from_element(config).push(mods_from_name(name))
                .flatten.compact,
      link: link_from_item(config),
      props: props_from_element(config),
      block_content: nil
    }
    config.is_a?(Hash) ? config.except([:mods]).merge(locals) : locals
  end

  def classes_from_element(config = {})
    # can be given as String…
    return classes_from_string(config) if config.is_a?(String)
    # or Hash[:mods] (String or Array)
    return [] unless config.is_a?(Hash) && config[:mods].present?
    case
    when config[:mods].is_a?(String) then classes_from_string(config[:mods])
    when config[:mods].is_a?(Array) then config[:mods]
    else []
    end
  end

  def mods_from_name(name)
    supported_elements = ['icon', 'button', 'tag-cloud', 'tag-button']
    mods = name.split('.')
    element = mods.shift(1).first
    return unless mods
    supported_elements.map do |supported|
      mods.map { |mod| "#{element}-#{mod}" } if element == supported
    end.flatten.compact
  end

  def build_list(list = nil)
    case
    when list.is_a?(Array)
      list.compact
    when list.is_a?(Hash) # only transform Hashes
      list = list.compact
      Hash[list.map { |id, itm| [id, build_locals_from_element(id.to_s, itm)] }]
    else
      list
    end
  end

  def props_from_element(config)
    return {} unless config.is_a?(Hash) && config[:props].is_a?(Hash)
    config[:props]
  end

  def name_without_mods(name)
    classes_from_string(name || '').first
  end

  def classes_from_string(string) # split by dot and spaces, always returns Array
    [string.split(/\.|\s/)].flatten.compact
  end

end
