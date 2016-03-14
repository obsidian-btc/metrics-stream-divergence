module Metrics
  module Stream
    module Divergence
      module Controls
        module Data
          def self.example
            data = Measure::Data.build

            data.started_time = Controls::Time.earlier
            data.ended_time = Controls::Time.later

            data.add 'stream_1', Controls::Time.earlier
            data.add 'stream_2', Controls::Time.later

            data
          end

          module JSON
            def self.text
              ::JSON.generate(data)
            end

            # def self.data
            #   [
            #     {
            #       'streamName' => 'stream_1',
            #       'time' => Controls::Time.earlier
            #     },
            #     {
            #       'streamName' => 'stream_2',
            #       'time' => Controls::Time.later
            #     }
            #   ]
            # end

            def self.data
              {
                'startedTime' => Controls::Time.earlier,
                'endedTime' => Controls::Time.later,
                'points' => [
                  {
                    'streamName' => 'stream_1',
                    'time' => Controls::Time.earlier
                  },
                  {
                    'streamName' => 'stream_2',
                    'time' => Controls::Time.later
                  }
                ]
              }
            end
          end
        end
      end
    end
  end
end
