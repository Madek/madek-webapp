# NOTE: as the name indicates, only used in test env
class OnlyForTestController < ApplicationController
  def error_500
    raise 'error 500'
  end

  # Regression test for #946: catches a genuine DB-level abort locally (like
  # a real controller's rescue block would), calls `redirect_to` -- which
  # should heal the connection -- and then writes to the DB again. If the
  # heal didn't happen, this write silently fails to persist (connection
  # still aborted at that point), which the spec observes as a missing
  # Group row, without needing the request itself to crash.
  def redirect_then_query
    skip_authorization

    begin
      ActiveRecord::Base.connection.execute('SELECT 1/0')
    rescue ActiveRecord::StatementInvalid
    end

    redirect_to status_path

    begin
      Group.create!(name: 'Test Group After Redirect')
    rescue ActiveRecord::StatementInvalid
    end
  end
end
