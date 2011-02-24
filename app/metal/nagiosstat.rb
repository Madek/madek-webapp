# -*- encoding : utf-8 -*-

class Nagiosstat
  def self.call(env)
      # generate some status for sphinx. We check to see if the searchdaemon is up for our current environment and rails root
      sphinx_status = "sphinx:" + (ThinkingSphinx.sphinx_running? ? 0 : 2).to_s
      # test to see if we can communicate with the database
      db_status = "database:" + begin
        MediaFile.count
        0
      rescue
        2
      end.to_s

      results = [sphinx_status, db_status].join("\n")

      [200, {"Content-Type" => "text/html"}, [ results ]]
  end
end
