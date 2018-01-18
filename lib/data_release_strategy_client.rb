module DataReleaseStrategyClient
  @@STRATEGIES = nil

  def self.STRATEGIES
    if @@STRATEGIES.nil?
      @@STRATEGIES = 5.times.map do |num|
        DataReleaseStrategy.new(name: "Study-#{num}", uuid: SecureRandom.uuid)
      end.freeze
    end
    @@STRATEGIES
  end

  class DataReleaseStrategy
    attr_accessor :name, :uuid

    def initialize(params={})
      @name=params[:name]
      @uuid = params[:uuid]
    end

    def self.find_by_uuid(uuid)
      if uuid
        DataReleaseStrategyClient.STRATEGIES.select do |d| 
          d.uuid == uuid
        end.first
      end
    end

    def to_json
      { data_release_strategy: { name: name, uuid: uuid } }.to_json
    end

  end

  def self.get_strategies_for_user(user)
    DataReleaseStrategyClient.STRATEGIES
  end
end