module Metrics
  module Stream
    module Divergence
      module Controls
        module Time
          def self.earlier(time=nil)
            time ||= reference
            Clock::UTC.iso8601(time)
          end

          def self.later(time=nil, divergence_milliseconds: nil)
            time ||= reference
            divergence_milliseconds ||= unit

            time += divergence_milliseconds

            Clock::UTC.iso8601(time)
          end

          def self.reference
            ::Controls::Time::Raw.example
          end

          def self.unit(multiple=nil)
            multiple ||= 1
            (multiple / 1000.0)
          end

          module Measurement
            def self.example(time=nil)
              time ||= Time.reference
            end

            def self.iso8601(time=nil)
              time ||= example(time)
              Clock::UTC.iso8601(time)              
            end

            module Started
              def self.example(time=nil)
                time = Measurement.example(time) + Time.unit
              end

              def self.iso8601(time=nil)
                time ||= example(time)
                Clock::UTC.iso8601(time)              
              end
            end

            module Ended
              def self.example(time=nil)
                time = Measurement.example(time) + Time.unit(2)
              end

              def self.iso8601(time=nil)
                time ||= example(time)
                Clock::UTC.iso8601(time)              
              end
            end
          end
        end
      end
    end
  end
end
