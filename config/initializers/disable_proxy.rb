# Disables proxy settings for server
if !Rails.env.test?
  ENV['HTTP_PROXY'] = nil
  ENV['http_proxy'] = nil
  ENV['https_proxy'] = nil
end
