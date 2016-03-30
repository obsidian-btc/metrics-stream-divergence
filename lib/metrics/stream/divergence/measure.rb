module Metrics
  module Stream
    module Divergence
      class Measure
        class Error < RuntimeError; end

        attr_reader :stream_names

        dependency :clock, Clock::UTC
        dependency :logger, Telemetry::Logger

        def initialize(stream_names)
          @stream_names = stream_names
        end

        def self.build(stream_name_1, stream_name_2, *stream_names)
          stream_names = [stream_name_1, stream_name_2, *stream_names]

          new(stream_names).tap do |instance|
            Clock::UTC.configure instance
            Telemetry::Logger.configure instance
          end
        end

        def self.configure(receiver, stream_name_1, stream_name_2, *stream_names_and_attr_name)
          if stream_names_and_attr_name.last.is_a? Symbol
            attr_name = stream_names_and_attr_name.pop
          end
          stream_names = stream_names_and_attr_name

          attr_name ||= :measure

          build(stream_name_1, stream_name_2, *stream_names).tap do |instance|
            receiver.send "#{attr_name}=", instance
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

        module Substitute
          def self.build
            Measure.new
          end

          class Measure
            attr_accessor :data

            def call
              data
            end
          end
        end
      end
    end
  end
end
