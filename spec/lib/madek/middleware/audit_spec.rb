require 'spec_helper'

describe Madek::Middleware::Audit do
  let(:env) do
    {
      'REQUEST_METHOD' => 'POST',
      'REQUEST_PATH' => '/test',
      'HTTP_HTTP_UID' => nil,
      'HTTP_COOKIE' => nil
    }
  end

  # Regression test for #946: proves the middleware itself refuses to
  # silently succeed when the app swallows a DB-level error and never heals
  # or re-raises -- independent of any per-app controller-level fix
  # (TransactionHealing), which a raw Rack app bypasses entirely.
  it 'raises instead of silently succeeding when the app leaves the connection aborted' do
    app_that_swallows_the_abort = lambda do |_env|
      begin
        ActiveRecord::Base.connection.execute('SELECT 1/0')
      rescue ActiveRecord::StatementInvalid
      end
      [200, {}, ['OK']]
    end

    middleware = described_class.new(app_that_swallows_the_abort)

    expect { middleware.call(env) }
      .to raise_error(Madek::Middleware::Audit::TransactionAbortedError)
  end

  it 'returns the response normally when nothing is aborted' do
    ok_app = ->(_env) { [200, {}, ['OK']] }
    response = described_class.new(ok_app).call(env)
    expect(response.first).to eq(200)
  end
end
