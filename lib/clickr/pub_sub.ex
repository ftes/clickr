defmodule Clickr.PubSub do
  use Boundary, exports: [], deps: []

  alias Phoenix.PubSub

  def broadcast(topic, msg) do
    PubSub.broadcast(__MODULE__, topic, msg)
  end

  def subscribe(topic) do
    PubSub.subscribe(__MODULE__, topic)
  end

  def unsubscribe(topic) do
    PubSub.unsubscribe(__MODULE__, topic)
  end
end
