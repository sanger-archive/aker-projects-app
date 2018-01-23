require "faraday"
require "zipkin-tracer"
require 'uuid'


# Client to access the Data release strategies, currently accessed from Sequencescape
module DataReleaseStrategyClient

  # Whenever a new Nodeform is saved, it checks with the data relese server if the
  # current user has rights to use the selected strategy. If not, it will set an error
  # message that the UI will display in the modal for the form
  class DataReleaseStrategyValidator < ActiveModel::Validator
    def validate(record)
      return if record.data_release_strategy_id.nil?
      unless UUID.validate(record.data_release_strategy_id)
        record.errors[:data_release_strategy_id] << 'The value for data release strategy selected is not a UUID'
        return
      end
      value = nil
      begin
        value = DataReleaseStrategyClient.find_strategies_by_user(record.current_user.email).any? do |strategy| 
          strategy.id == record.data_release_strategy_id
        end
      rescue Faraday::ConnectionFailed => e
        value = nil
        record.errors[:data_release_strategy_id] << 'There is no connection with the Data release service. Please contact with the administrator'
        return
      end
      unless value
        record.errors[:data_release_strategy_id] << 'The current user cannot select the Data release strategy provided.'
        return
      end
    end
  end


  # Returns the data release strategy by uuid.
  def self.find_strategy_by_uuid(uuid)
    if uuid
      DataReleaseStrategy.find_by(id: uuid)
    end
  end

  # Gets the list of strategies available for the user. It also updates the current database with 
  # the response, as this keeps the local copy for the name of data releases up to date
  def self.find_strategies_by_user(user)
    conn = get_connection
    
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

  # Connection to access the data release server
  def self.get_connection
    conn = Faraday.new(:url => Rails.application.config.urls[:data_release]) do |faraday|
      faraday.use ZipkinTracer::FaradayHandler, 'Sequencescape'
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter
    end
    conn.headers = {'Accept' => 'application/vnd.api+json', 'Content-Type' => 'application/vnd.api+json'}
    conn
  end

end


