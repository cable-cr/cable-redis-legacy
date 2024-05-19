# cable-redis-legacy

This is a [Cable.cr](https://github.com/cable-cr/cable) backend extension for [stefanwille/crystal-redis](https://github.com/stefanwille/crystal-redis).

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     cable:
       github: cable-cr/cable
     cable-redis:
       github: cable-cr/cable-redis-legacy
   ```

2. Run `shards install`

## Usage

```crystal
require "cable"
require "cable-redis"

Cable.configure do |settings|
  settings.url = ENV.fetch("CABLE_BACKEND_URL", "redis://localhost:6379")
  settings.backend_class = Cable::RedisLegacyBackend

  # Additional settings for using a pooled client
  # Only available with this shard extension
  settings.pool_redis_publish = false
  settings.redis_pool_size = 5
  settings.redis_pool_timeout = 5.0
  # ... all other Cable config settings
end
```

## Development

1. Make the update
2. Add a spec and run `crystal spec`
3. Format it `crystal tool format spec/ src/`
4. Ameba `./bin/ameba`
5. Commit it
6. GO TO 1

## Contributing

1. Fork it (<https://github.com/cable-cr/cable-redis/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Jeremy Woertink](https://github.com/jwoertink) - creator and maintainer