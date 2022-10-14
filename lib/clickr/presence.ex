defmodule Clickr.Presence do
  use Phoenix.Presence,
    otp_app: :clickr,
    pubsub_server: Clickr.PubSub

  def gateway_topic(%{user_id: uid}), do: "presence.gateway/user:#{uid}"

  def track_gateway(%{gateway_id: gid, user_id: _} = args) do
    {:ok, _} = track(self(), gateway_topic(args), gid, %{})
  end
end
