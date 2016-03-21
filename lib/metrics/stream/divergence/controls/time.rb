module Metrics
  module Stream
    module Divergence
      module Controls
        module Time
          def self.earlier(time=nil)
            time ||= Reference.example
            Clock::UTC.iso8601(time)
          end

          def self.later(time=nil, divergence_milliseconds: nil)
            time ||= Reference.example
            divergence_milliseconds ||= unit

            time += divergence_milliseconds

            Clock::UTC.iso8601(time)
          end

          def self.unit
            (1.0 / 1000)
          end

          module Reference
            def self.text
              ::Controls::Time::ISO8601.example
            end

            def self.example
              ::Controls::Time::Raw.example
            end
          end
        end
      end
    end
  end
end
