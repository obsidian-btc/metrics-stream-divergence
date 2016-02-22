# metrics-stream-divergence

Calculates the difference in milliseconds between the timestamps of the most recent events in two or more EventStore streams.

## Rationale

The difference in time between two streams can be used to detect whether a service is processing commands at a reasonable rate.

For example, the difference in time between a services inbound commands and the events that are emitted as a result of those commands can indicate the service's processing latency. If that latency exceeds a given value, an alert should be sent to whatever alert deliver system is in-use.

## Usage

```ruby
divergence = Metrics::Stream::Divergence::Measure.('some_stream_name', 'some_other_stream_name')

puts divergence.elapsed_milliseconds
```

## License

The `metrics-stream-divergence` library is released under the [MIT License](https://github.com/obsidian-btc/metrics-stream-divergence/blob/master/MIT-License.txt).
