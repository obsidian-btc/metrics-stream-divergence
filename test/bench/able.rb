require_relative './bench_init'

context "Divergence Data isn't Able" do
  divergence = Measure::Data.build

  test "When there are less than two data points" do
    assert(!divergence.able?)
  end

  context "Calculating elapsed milliseconds" do
    test "Is an error" do
      assert proc { divergence.elapsed_milliseconds } do
        raises_error? Measure::Error
      end
    end
  end
end
