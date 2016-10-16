class AimsController < ApplicationController
  def show
    @aim = Aim.find(params[:id])
  end
end
