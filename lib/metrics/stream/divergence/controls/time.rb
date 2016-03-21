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
            divergence_milliseconds ||= (1.0 / 1000)

            time += divergence_milliseconds

            Clock::UTC.iso8601(time)
          end

          module Reference
            def self.text
              "Jan 1 1:00:00 Z 2000"
            end

            def self.example
              ::Time.parse(text)
            end
          end
        end
      end
    end
  end
end
