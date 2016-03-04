module Metrics
  module Stream
    module Divergence
      class Measure
        class Data
          dependency :logger
          dependency :clock

          def self.build
            new.tap do |instance|
              Clock::UTC.configure instance
              Telemetry::Logger.configure instance
            end
          end

          def points
            @points ||= []
          end

          def min
            points.min { |a, b| a.time <=> b.time }
          end

          def max
            points.max { |a, b| a.time <=> b.time }
          end

          def sort
            points.sort do |a, b|
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

            points << point

            point
          end

          def elapsed_milliseconds
            unless able?
              error_message = "Cannot calculate elapsed milliseconds with #{points.length} data points (2 or more are required)"
              logger.error error_message

              raise Error, error_message
            end

            (max.time - min.time) * 1000
          end

          def able?
            points.length >= 2
          end

          Point = Struct.new(:stream_name, :time)
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
