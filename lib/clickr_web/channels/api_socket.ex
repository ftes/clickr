defmodule ClickrWeb.ApiSocket do
  use Phoenix.Socket

  # A Socket handler
  #
  # It's possible to control the websocket connection and
  # assign values that can be accessed by your channel topics.

  ## Channels

  channel "deconz", ClickrWeb.DeconzChannel

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  @impl true
  def connect(%{"api_token" => api_token}, socket, _connect_info) do
    case Clickr.Devices.get_gateway_by(api_token: api_token) do
      nil ->
        {:error, :invalid_api_token}

      gateway ->
        user = Clickr.Accounts.get_user!(gateway.user_id)

        {:ok, assign(socket, api_token: api_token, current_user: user, current_gateway: gateway)}
    end
  end

  def connect(_params, _socket, _connect_info) do
    {:error, :invalid_api_token}
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     Elixir.ClickrWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  @impl true
  def id(socket), do: "api_token:#{socket.assigns.api_token}"
end
