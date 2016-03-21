module Metrics
  module Stream
    module Divergence
      module Controls
        module Data
          def self.example(earlier: nil, later: nil)
            earlier ||= Controls::Time.earlier
            later ||= Controls::Time.later

            data = Measure::Data.build

            data.started_time = Time::Measurement::Started.iso8601
            data.ended_time = Time::Measurement::Ended.iso8601

            data.add 'stream_1', earlier
            data.add 'stream_2', later

            data
          end

          module JSON
            def self.text
              ::JSON.generate(data)
            end

            def self.data
              earlier = Controls::Time.earlier
              later = Controls::Time.later

              {
                'elapsedMilliseconds' => Clock.elapsed_milliseconds(earlier, later),
                'streams' => [
                  {
                    'name' => 'stream_1',
                    'time' => Controls::Time.earlier
                  },
                  {
                    'name' => 'stream_2',
                    'time' => Controls::Time.later
                  },
                ],
                'startedTime' => Time::Measurement::Started.iso8601,
                'endedTime' => Time::Measurement::Ended.iso8601
              }
            end
          end
        end
      end
    end
  end
end
