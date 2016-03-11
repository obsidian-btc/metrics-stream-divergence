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

            clock.elapsed_milliseconds(min.time, max.time)
          end

          def able?
            points.length >= 2
          end

          Point = Struct.new(:stream_name, :time)

          module Serializer
            def self.json
              JSON
            end

            def self.raw_data(instance)
              raw_data = []

              instance.points.each do |point|
                point_data = {}
                point_data[:stream_name] = point.stream_name
                point_data[:time] = Clock::UTC.iso8601(point.time)
                raw_data << point_data
              end

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
