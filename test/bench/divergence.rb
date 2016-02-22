require_relative './bench_init'

context "Stream Divergence" do
  stream_name_1 = Metrics::Stream::Divergence::Controls::Writer.write 1, 'stream_1'
  stream_name_2 = Metrics::Stream::Divergence::Controls::Writer.write 1, 'stream_2'
  stream_name_3 = Metrics::Stream::Divergence::Controls::Writer.write 1, 'stream_3'

  divergence = Measure.(stream_name_1, stream_name_2, stream_name_3)

  test "The difference between timestamps of the last events of each stream" do
    assert(divergence.milliseconds > 0)
  end

  context "Index by time" do
    test "First stream is the earliest" do
      assert(divergence.index(stream_name_1) == 0)
    end

    test "Last stream is the latest" do
      assert(divergence.index(stream_name_3) == 2)
    end
  end
end
