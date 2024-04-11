import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :clickr, Clickr.Repo,
  database: Path.expand("../clickr_test.db", Path.dirname(__ENV__.file)),
  pool_size: 1,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :clickr, ClickrWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "pYXxDCCMK/uG9+K5wEzLzuYpUsS0wrN+D0+FRD49TD23DrUtDurOpbCdOvRxPSYG",
  server: false

# In test we don't send emails.
config :clickr, Clickr.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :clickr, Clickr.Zigbee2Mqtt.Connection, disabled: true
config :clickr, Clickr.Zigbee2Mqtt.Gateway, timeout: 20, heartbeat: 10
