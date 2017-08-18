class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include AkerAuthenticationGem::AuthController
  include JWTCredentials
  include AkerPermissionControllerConfig

  layout :layout

  private

  def layout
    # only turn it off for login pages:
    is_a?(Devise::SessionsController) ? "login_application" : "application"
  end

  def current_user
    return @x_auth_user if @x_auth_user && @x_auth_user.email!='guest'
    warden.authenticate(scope: :user)
  end

end
