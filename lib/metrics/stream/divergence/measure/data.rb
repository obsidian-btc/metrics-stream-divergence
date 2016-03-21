module Metrics
  module Stream
    module Divergence
      class Measure
        class Data
          dependency :clock
          dependency :logger

          attr_accessor :started_time
          attr_accessor :ended_time

          def self.build
            new.tap do |instance|
              Clock::UTC.configure instance
              Telemetry::Logger.configure instance
            end
          end

          def streams
            @streams ||= []
          end

          def min
            streams.min { |a, b| a.time <=> b.time }
          end

          def max
            streams.max { |a, b| a.time <=> b.time }
          end

          def sort
            streams.sort do |a, b|
              a.time <=> b.time
            end
          end

          def index(stream_name)
            sort.index { |p| p.stream_name == stream_name }
          end

          def add(stream_name, time)
            time = clock.parse(time) if time.is_a?(String)
            time = clock.canonize(time)

            point = Point.new(stream_name, time)

            streams << point

            point
          end

          def elapsed_milliseconds
            unless able?
              error_message = "Cannot calculate elapsed milliseconds with #{streams.length} data streams (2 or more are required)"
              logger.error error_message

              raise Error, error_message
            end

            clock.elapsed_milliseconds(min.time, max.time)
          end

          def able?
            streams.length >= 2
          end

          Point = Struct.new(:stream_name, :time)

          module Serializer
            def self.json
              JSON
            end

            def self.raw_data(instance)
              raw_data = {}

              raw_data[:elapsed_milliseconds] = instance.elapsed_milliseconds

              streams = []

              instance.streams.each do |point|
                point_data = {}
                point_data[:name] = point.stream_name
                point_data[:time] = Clock::UTC.iso8601(point.time)
                streams << point_data
              end

              raw_data[:streams] = streams

              raw_data[:started_time] = instance.started_time
              raw_data[:ended_time] = instance.ended_time

              raw_data
            end

            module JSON
              def self.serialize(raw_data)
                formatted_data = Casing::Camel.(raw_data)
                ::JSON.generate(formatted_data)
              end
            end
          end
        end

        module LogText
          def self.stream_names(stream_names)
            stream_names.join(', ')
          end
        end
      end
    end
  end
end
