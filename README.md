# metrics-stream-divergence

Calculates the difference in milliseconds between the timestamps of the most recent events in two or more EventStore streams.

## Usage

```ruby
divergence = Metrics::Stream::Divergence::Measure.('some_stream_name', 'some_other_stream_name')

puts divergence.elapsed_milliseconds
```

## License

The `metrics-stream-divergence` library is released under the [MIT License](https://github.com/obsidian-btc/metrics-stream-divergence/blob/master/MIT-License.txt).
