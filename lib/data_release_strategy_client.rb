module DataReleaseStrategyClient
  @@STRATEGIES = nil

  def self.STRATEGIES
    if @@STRATEGIES.nil?
      @@STRATEGIES = 5.times.map do |num|
        DataReleaseStrategy.find_or_create_by(name: "Study-#{num}")
      end
    end
    @@STRATEGIES.each(&:reload)
    @@STRATEGIES
  end

  def self.find_strategy_by_uuid(uuid)
    if uuid
      DataReleaseStrategyClient.STRATEGIES.select do |d| 
        d[:id] == uuid
      end.first
    end
  end

  def self.find_strategies_by_user(user)
    DataReleaseStrategyClient.STRATEGIES
  end
end