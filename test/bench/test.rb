require_relative './bench_init'

context do
  test do
    Metrics::Stream::Divergence.()
  end  
end
