# This is to benchmark PostgreSQL on simfs vs. NFS vs. ploop

# Run inside a Rails console
class PsqlBenchmark

  def initialize(queries = [], logfile)
    @queries = queries
    @logfile = logfile
  end

  def run
    i = 0
    puts "Running #{queries.count} queries"
    @queries.each do |query|
      next if (query.blank? or query == "\n")
      runtimes = []
      10.times do
        runtimes << Benchmark.ms do
          ActiveRecord::Base.connection.select_value(query)
        end
      end
      @logfile.puts(query + "\n" + runtimes.join(',') + "\n")
      i += 1
      puts "Query #{i}/#{queries.count} done"
    end
  end

end

queries = \
  File
    .read("#{Rails.root}/doc/benchmark_postgresql_queries.sql")
    .split(';')

logfile = File.open('/tmp/benchmark_result.txt', 'w+')
bm = PsqlBenchmark.new(queries, logfile)
bm.run
logfile.close
