defmodule ClickrWeb.GatewayLive.FormComponent do
  use ClickrWeb, :live_component

  alias Clickr.Devices

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="gateway-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :name}} type="text" label={dgettext("devices.gateways", "Name")} />
        <.input field={{f, :api_token}} type="text" label={dgettext("devices.gateways", "API Token")} />
        <:actions>
          <.button phx-disable-with={gettext("Saving...")}><%= gettext("Save") %></.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{gateway: gateway} = assigns, socket) do
    changeset = Devices.change_gateway(gateway)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"gateway" => gateway_params}, socket) do
    changeset =
      socket.assigns.gateway
      |> Devices.change_gateway(gateway_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"gateway" => gateway_params}, socket) do
    save_gateway(socket, socket.assigns.action, gateway_params)
  end

  defp save_gateway(socket, :edit, gateway_params) do
    # TODO Check permission

    case Devices.update_gateway(socket.assigns.gateway, set_user_id(socket, gateway_params)) do
      {:ok, _gateway} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext("devices.gateways", "Gateway updated successfully"))
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_gateway(socket, :new, gateway_params) do
    case Devices.create_gateway(set_user_id(socket, gateway_params)) do
      {:ok, _gateway} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext("devices.gateways", "Gateway created successfully"))
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp set_user_id(socket, params), do: Map.put(params, "user_id", socket.assigns.current_user.id)
end
