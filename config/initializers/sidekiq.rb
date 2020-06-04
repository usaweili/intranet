Sidekiq.configure_server do |config|
  config.error_handlers << Proc.new {|ex,ctx_hash| Rnotifier.exception(ex, {:context_params => ctx_hash}) }
  config.redis = { url: ENV["REDIS_SESSIONS_URL"] }
end
Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDIS_SESSIONS_URL"] }
end
