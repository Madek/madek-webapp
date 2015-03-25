class Presenter

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
    Hash[
      api.map do |api_method|
        result = \
          begin
            send(api_method)
          rescue => e
            "ERROR: #{e.message}"
          end

        [api_method, Presenter.dump_recur(result)]
      end
    ]
  end

  def self.dump_recur(obj)
    if obj.is_a?(Presenter)
      obj.dump
    elsif obj.is_a?(Array)
      obj.map { |elt| dump_recur(elt) }
    elsif obj.is_a?(Hash)
      obj
        .map { |k, v| [k, dump_recur(v)] }
        .to_h
    elsif obj.class.name.match(/ActiveRecord/)
      "!!!ACTIVE_RECORD!!! <##{obj.class}>"
    elsif obj.class.superclass.name.match(/ActiveRecord/)
      "!!!ACTIVE_RECORD!!! #{obj}"
    else
      obj
    end
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
end
