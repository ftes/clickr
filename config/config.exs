# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :clickr,
  ecto_repos: [Clickr.Repo],
  generators: [binary_id: true]

config :clickr, Clickr.Repo,
  migration_primary_key: [type: :binary_id],
  migration_foreign_key: [type: :binary_id]

# Configures the endpoint
config :clickr, ClickrWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: ClickrWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Clickr.PubSub,
  live_view: [signing_salt: "7WwbuSgV"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :clickr, Clickr.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.0",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.17",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :bodyguard,
  # The second element of the {:error, reason} tuple returned on auth failure
  default_error: :unauthorized

config :clickr, Clickr.Zigbee2Mqtt.Connection,
  host: "d8a49c0682174333860981a8c709e3b4.s1.eu.hivemq.cloud",
  user: "clickr_server",
  password: "set $MQTT_PASSWORD env var",
  port: 8883

config :clickr, Clickr.Zigbee2Mqtt.Gateway, timeout: 10_000, heartbeat: 5_000

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
