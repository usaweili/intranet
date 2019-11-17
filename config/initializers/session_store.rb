# Be sure to restart your server when you modify this file.

#Intranet::Application.config.session_store :cookie_store, key: '_intranet_session'
if Rails.env.production?
  Intranet::Application.config.session_store :redis_store, key: '_intranet_session', serializer: :json, redis: {key: 'intranet:session:', url: ENV['REDIS_SESSIONS_URL']}
elsif Rails.env.staging?
  Intranet::Application.config.session_store :redis_store, key: '_stage_intranet_session', serializer: :json, redis: {key: 'stage-intranet:session:', url: ENV['REDIS_SESSIONS_URL']}
else
  Intranet::Application.config.session_store :cookie_store, key: '_intranet_session'
end
