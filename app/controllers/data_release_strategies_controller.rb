class DataReleaseStrategiesController < ApplicationController

  before_action :set_data_release_strategy, only: [:show]
  before_action :set_data_release_strategies, only: [:index]


  skip_authorization_check only: [:index, :show]

  def index
    render json: @data_release_strategies.to_json
  end

  def show
    render json: @data_release_strategy.to_json
  end

  private

  def set_data_release_strategies
    begin
      @data_release_strategies = DataReleaseStrategyClient.find_strategies_by_user(current_user.email)
    rescue Faraday::ConnectionFailed => e
      head :status => 404
    end
  end

  def set_data_release_strategy
    @data_release_strategy = DataReleaseStrategyClient.find_strategy_by_uuid(params[:id]) 
    head :status => 404 unless @data_release_strategy
    true
  end

end