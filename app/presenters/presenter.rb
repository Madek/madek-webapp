class Presenter

  include Presenters::Modules::DumpHelpers
  include Rails.application.routes.url_helpers
  include Presenters::Helpers::Helpers

  def api
    self_singleton_methods = self.singleton_methods
    self_class_methods = self
      .class
      .ancestors
      .take_while { |a| a.name.match(/^Presenters/) if a.name }
      .map { |a| a.instance_methods(false) }

    presenter_api_methods = (self_singleton_methods + self_class_methods)

    presenter_api_methods
      .flatten
      .uniq
      .reject { |m| m == :inspect }
      .push(:_presenter)
  end

  def _presenter
    return if Rails.env != 'development'
    self.class.name
  end

  def dump(sparse_spec: nil)
    sparse_spec.present? ? Presenter.deep_map(sparse_spec, self) : full_dump
  end

  def full_dump
    Hash[
      api
        .reject { |m| method(m).arity > 0 } # only dump methods without args
        .map do |api_method|
          result = \
            begin
              send(api_method)
            rescue => err
              # NOTE: "inline" errors disabled, must be integrated with responders
              # { type: :Error, error: err.inspect, location: err.backtrace.first }

              # just re-throw the error to behave normally in all envs
              # NOTE: doing anything else looses the stracktrace (ruby limitation)
              fail err
            end

          [api_method, Presenter.dump_recur(result)]
        end
    ]
  end

  def inspect
    app_resource_id = " app_resource_id: \"#{@app_resource.id}\"" if @app_resource
    # object_id returns half the object's memory address, so we need to multiply
    # by 2 to get the actual address and then convert to hex representation
    # https://stackoverflow.com/questions/4010547/object-address-in-ruby
    "#<#{self.class}:#{format('%#x', object_id * 2)}#{app_resource_id}>"
  end

  def to_s # in case it ends up undecorated in a view, .to_s is called!
    inspect
  end

  def to_h # ruby convention/compatibilty
    full_dump
  end

  def as_json # Rails/ActiveRecord convention/compatibilty
    full_dump
  end

  def type # not used in ruby land! (js models only)
    self.class.name.demodulize
  end

  private

  def prepend_url_context(url = '')
    # FIXME: RAILS BUG https://github.com/rails/rails/pull/17724
    context = Rails.application.routes.relative_url_root
    context.present? ? context + url : url
  end

end
