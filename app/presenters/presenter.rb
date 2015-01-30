class Presenter

  include Rails.application.routes.url_helpers

  def api
    self
      .class
      .ancestors
      .select { |a| a.to_s.match /^Presenters/ }
      .map { |a| a.instance_methods(false) }
      .flatten
  end

  def dump
    # TODO: recursion
    Hash[self.api.map { |m| [m, self.method(m).call] }]
  end
end
