# This is to benchmark PostgreSQL on simfs vs. NFS vs. ploop

# Run inside a Rails console
class PsqlBenchmark

  def initialize(queries = [], logfile)
    @queries = queries
    @logfile = logfile
  end

  def run
    @queries.each do |query|
      next if (query.blank? or query == "\n")
      runtimes = []
      10.times do
        runtimes << Benchmark.ms {
          ActiveRecord::Base.connection.select_value(query)
        }
      end
      @logfile.puts(query + "\n" + runtimes.join(",") + "\n")
    end
  end

end

queries = File.read("#{Rails.root}/doc/benchmark_postgresql_queries.sql").split(";")

logfile = File.open("/tmp/benchmark_result.txt", "w+")
bm = PsqlBenchmark.new(queries, logfile)
bm.run
logfile.close
