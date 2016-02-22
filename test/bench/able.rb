require_relative './bench_init'

context "Divergence Data isn't Able" do
  divergence = Measure::Data.build

  test "When there are less than two data points" do
    assert(!divergence.able?)
  end
end
