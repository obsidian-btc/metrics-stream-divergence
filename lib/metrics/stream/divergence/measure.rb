module Metrics
  module Stream
    module Divergence
      class Measure
        class Error < RuntimeError; end

        attr_reader :stream_names

        dependency :logger

        def initialize(*stream_names)
          @stream_names = stream_names
        end

        def self.build(*stream_names)
          new(*stream_names).tap do |instance|
            Telemetry::Logger.configure instance
          end
        end

        def self.call(*stream_names)
          instance = self.build(*stream_names)
          instance.()
        end

        def call
          logger.trace "Measuring stream divergence (Stream Names: #{LogText.stream_names(stream_names)})"

          data = divergence

          logger.info "Measured stream divergence (Stream Names: #{LogText.stream_names(stream_names)})"

          data
        end

        def divergence
          logger.trace "Calculating stream divergence (Stream Names: #{LogText.stream_names(stream_names)})"

          data = Data.build

          stream_names.each do |stream_name|
            time = get_tail_time(stream_name)
            data.add(stream_name, time) unless time.nil?
          end

          logger.debug "Stream divergence calculated (Stream Names: #{LogText.stream_names(stream_names)})"
          logger.data data.inspect

          data
        end

        def get_tail_time(stream_name)
          reader = build_reader(stream_name)

          events = []
          reader.each do |event|
            events << event
          end

          event = events[0]

          if event.nil?
            logger.debug "No events for stream (Stream Name: #{stream_name})"
            return nil
          end

          event.created_time
        end

        def build_reader(stream_name)
          EventStore::Client::HTTP::Reader.build stream_name, slice_size: 1, direction: :backward
        end

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
