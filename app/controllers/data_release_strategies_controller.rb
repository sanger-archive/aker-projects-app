class DataReleaseStrategiesController < ApplicationController

  before_action :set_data_release_strategy, only: [:show]
  before_action :set_data_release_strategies, only: [:index]


  skip_authorization_check only: [:index, :show]

  def index
    render json: @data_release_strategies
  end

  def show
    render json: @data_release_strategy
  end

  private

  # Gets the list of strategies for the current user. It returns a 404 if there is no connection
  def set_data_release_strategies
    begin
      @data_release_strategies = DataReleaseStrategyClient.find_strategies_by_user(current_user.email)
    rescue Faraday::ConnectionFailed => e
      head :not_found
    end
  end

  # Gets the info from the strategy shown. It returns a 404 if it does not exist
  def set_data_release_strategy
    @data_release_strategy = DataReleaseStrategyClient.find_strategy_by_uuid(params[:id]) 
    head :not_found unless @data_release_strategy
    true
  end

end