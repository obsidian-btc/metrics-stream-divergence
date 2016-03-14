require_relative './bench_init'

context "Stream that Doesn't Exist" do
  stream_name_1 = Identifier::UUID::Random.get.gsub('-', '')
  stream_name_2 = Identifier::UUID::Random.get.gsub('-', '')

  divergence = Measure.(stream_name_1, stream_name_2)

  test "Isn't included in the measurement data" do
    assert(divergence.streams.length == 0)
  end
end
