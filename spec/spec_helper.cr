require "spec"
require "../src/cable-redis-legacy"
require "./support/*"

Cable.configure do |settings|
  settings.route = "/updates"
  settings.token = "test_token"
  settings.url = ENV.fetch("CABLE_BACKEND_URL", "redis://localhost:6379")
  settings.backend_class = Cable::RedisLegacyBackend
  settings.backend_ping_interval = 2.seconds
  settings.restart_error_allowance = 2
end

Spec.before_each do
  Cable.restart
end
