require "redis"
require "./ext/*"

module Cable
  Habitat.extend do
    # These settings extend `Cable.settings` so you can use a `PooledClient`
    setting pool_redis_publish : Bool = false
    setting redis_pool_size : Int32 = 5
    setting redis_pool_timeout : Float64 = 5.0
  end

  class RedisLegacyBackend < Cable::BackendCore
    VERSION = "0.1.0"
    register "redis"  # redis://
    register "rediss" # rediss://

    getter redis_subscribe : Redis = Redis.new(url: Cable.settings.url)
    getter redis_publish : Redis::PooledClient | Redis do
      if Cable.settings.pool_redis_publish
        Redis::PooledClient.new(
          url: Cable.settings.url,
          pool_size: Cable.settings.redis_pool_size,
          pool_timeout: Cable.settings.redis_pool_timeout.seconds
        )
      else
        Redis.new(url: Cable.settings.url)
      end
    end

    # connection management
    def subscribe_connection : Redis
      redis_subscribe
    end

    def publish_connection : Redis::PooledClient | Redis
      redis_publish
    end

    def close_subscribe_connection
      return if redis_subscribe.nil?

      request = Redis::Request.new
      request << "unsubscribe"
      redis_subscribe._connection.send(request)
      redis_subscribe.close
    end

    def close_publish_connection
      return if redis_publish.nil?

      redis_publish.close
    end

    # internal pub/sub
    def open_subscribe_connection(channel)
      return if redis_subscribe.nil?

      redis_subscribe.subscribe(channel) do |on|
        on.message do |subscribed_channel, message|
          if subscribed_channel == "_internal" && message == "ping"
            Cable::Logger.debug { "Cable::Server#subscribe -> PONG" }
          elsif subscribed_channel == "_internal" && message == "debug"
            Cable.server.debug
          else
            Cable.server.fiber_channel.send({subscribed_channel, message})
            Cable::Logger.debug { "Cable::Server#subscribe channel:#{subscribed_channel} message:#{message}" }
          end
        end
      end
    end

    # external pub/sub
    def publish_message(stream_identifier : String, message : String)
      return if redis_publish.nil?

      redis_publish.publish(stream_identifier, message)
    end

    # channel management
    def subscribe(stream_identifier : String)
      return if redis_subscribe.nil?

      request = Redis::Request.new
      request << "subscribe"
      request << stream_identifier
      redis_subscribe._connection.send(request)
    end

    def unsubscribe(stream_identifier : String)
      return if redis_subscribe.nil?

      request = Redis::Request.new
      request << "unsubscribe"
      request << stream_identifier
      redis_subscribe._connection.send(request)
    end

    # ping/pong

    def ping_subscribe_connection
      Cable.server.publish("_internal", "ping")
    end

    def ping_publish_connection
      request = Redis::Request.new
      request << "ping"
      result = redis_subscribe._connection.send(request)
      Cable::Logger.debug { "Cable::BackendPinger.ping_publish_connection -> #{result}" }
    end
  end
end
