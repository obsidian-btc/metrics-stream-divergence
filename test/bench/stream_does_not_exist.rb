require_relative './bench_init'

context "Stream that Doesn't Exist" do
  stream_name = Identifier::UUID::Random.get.gsub('-', '')

  divergence = Measure.(stream_name)

  test "Isn't included in the measurement data" do
    assert(divergence.points.length == 0)
  end
end
