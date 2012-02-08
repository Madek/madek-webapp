# -*- encoding : utf-8 -*-

class Nagiosstat
  def self.call(env)
      # test to see if we can communicate with the database
      db_status = "database:" + begin
        MediaResource.count
        0
      rescue
        2
      end.to_s

      results = [db_status].join("\n")

      [200, {"Content-Type" => "text/html"}, [ results ]]
  end
end
