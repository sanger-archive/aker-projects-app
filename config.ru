# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

# Use config.app_mount_dir only if it's been set to something other than an
# empty string. Otherwise, use default of /
map Rails.application.config.app_mount_dir || '/' do
  run Rails.application
end
