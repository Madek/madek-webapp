class Presenter

  include Presenters::Modules::DumpHelpers
  include Rails.application.routes.url_helpers

  def api
    self
      .class
      .ancestors
      .select { |a| a.to_s.match(/^Presenters/) }
      .map { |a| a.instance_methods(false) }
      .flatten
      .uniq
      .reject { |m| m == :inspect }
  end

  def dump
    sparse_spec = sparse # do a "sparse dump" if there a spec on "self.sparse"
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
              { type: :Error, error: err.inspect, location: err.backtrace.first }
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

  def sparse # this returns a "include-all" sparse config hash, to be overwritten
    nil
  end

  def sparse_preset # this returns a "include-all" sparse config hash
    self.api.map { |k| [k, {}] }.to_h
  end

  def prepend_url_context_fucking_rails(url = '')
    # FIX FOR https://github.com/rails/rails/pull/17724
    context = Rails.application.routes.relative_url_root
    context.present? ? context + url : url
  end

end
