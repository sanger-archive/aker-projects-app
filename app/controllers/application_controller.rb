class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include JWTCredentials

  layout :layout

  private

  def layout
    # only turn it off for login pages:
    is_a?(Devise::SessionsController) ? "login_application" : "application"
  end


end
