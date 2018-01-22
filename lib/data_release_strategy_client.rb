require "faraday"
require "zipkin-tracer"

module DataReleaseStrategyClient

  class DataReleaseStrategyValidator < ActiveModel::Validator
    def validate(record)
      return true if record.data_release_strategy_id.blank?

      username = record.current_user.email.gsub(/@.*/,'')
      begin
        value = DataReleaseStrategyClient.find_strategies_by_user(username).any? do |strategy| 
          strategy.id == record.data_release_strategy_id
        end
      rescue Faraday::ConnectionFailed => e
        value = nil
      end
      unless value
        record.errors[:data_release_strategy_id] << 'The current user cannot select the Data release strategy provided.'
        return false
      end
      true
    end
  end


  def self.find_strategy_by_uuid(uuid)
    if uuid
      DataReleaseStrategyClient.find_by(id: uuid)
    end
  end

  def self.find_strategies_by_user(user)
    conn = get_connection
    conn.headers = {'Accept' => 'application/vnd.api+json'}
    username = user.gsub(/@.*/, '')
    studies = JSON.parse(conn.get('/api/v2/studies?filter[state]=active&filter[user]='+username).body)['data']

    studies.map do |study|
      strategy = DataReleaseStrategy.find_or_create_by(id: study['attributes']['uuid'])
      if strategy.name != study['attributes']['name']
        strategy.update_attributes(name: study['attributes']['name'])
      end
      strategy
    end.uniq
  end

  def self.get_connection
    conn = Faraday.new(:url => Rails.application.config.urls[:data_release]) do |faraday|
      faraday.use ZipkinTracer::FaradayHandler, 'Sequencescape'
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter
    end
    conn.headers = {'Content-Type' => 'application/vnd.api+json'}
    conn
  end

end


