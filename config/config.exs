# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :hive, HiveWeb.Endpoint,
  secret_key_base: "F113fMyRqvQgpbA3vpTQ/VeDtb91ZJ2UceWnJWOgiLKl4sau1mou+WyuecB+1F8H",
  render_errors: [view: HiveWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Hive.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
