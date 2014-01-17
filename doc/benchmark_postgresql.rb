# This is to benchmark PostgreSQL on simfs vs. NFS vs. ploop

# Run inside a Rails console
class PsqlBenchmark

  def initialize(queries = [], logfile)
    @queries = queries
    @logfile = logfile
  end

  def run
    runtimes = []
    @queries.each do |query|
      10.times do
        runtimes << Benchmark.ms {
          ActiveRecord::Base.connection.select_value(query)
        }
        sleep 10
      end
      @logfile.puts(query + "\n" + runtimes.join(",") + "\n")
    end
  end

end

queries = File.read("benchmark_postgresql_queries.sql").join.split(";")
binding.pry

logfile = File.open("/tmp/benchmark_result.txt", "w+")
bm = PsqlBenchmark.new(queries, logfile)
bm.run
logfile.close
