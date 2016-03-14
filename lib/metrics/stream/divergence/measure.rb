module Metrics
  module Stream
    module Divergence
      class Measure
        class Error < RuntimeError; end

        attr_reader :stream_names

        dependency :logger
        dependency :clock

        def initialize(*stream_names)
          @stream_names = stream_names
        end

        def self.build(stream_name_1, stream_name_2, *stream_names)
          stream_names.unshift(stream_name_2)
          stream_names.unshift(stream_name_1)

          new(*stream_names).tap do |instance|
            Clock::UTC.configure instance
            Telemetry::Logger.configure instance
          end
        end

        def self.call(stream_name_1, stream_name_2, *stream_names)
          instance = self.build(stream_name_1, stream_name_2, *stream_names)
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

          data.started_time = clock.iso8601

          stream_names.each do |stream_name|
            time = get_tail_time(stream_name)
            data.add(stream_name, time) unless time.nil?
          end

          data.ended_time = clock.iso8601

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
      end
    end
  end
end
