defmodule Clickr.Devices do
  use Boundary,
    exports: [Button, Device, Gateway],
    deps: [Clickr.{Accounts, PubSub, Repo, Schema}]

  defdelegate authorize(action, user, params), to: Clickr.Devices.Policy

  import Ecto.Query, warn: false
  alias Clickr.Repo
  alias Clickr.Accounts.User
  alias Clickr.Devices.{Button, Device, Gateway, Keyboard}

  def list_gateways(%User{} = user, opts \\ []) do
    Gateway
    |> Bodyguard.scope(user)
    |> where_ids(opts[:ids])
    |> where_online(opts[:online])
    |> Repo.all()
    |> _preload(opts[:preload])
  end

  def get_gateway!(%User{} = user, id, opts \\ []) do
    Gateway
    |> Bodyguard.scope(user)
    |> Repo.get!(id)
    |> _preload(opts[:preload])
  end

  def create_gateway(%User{} = user, attrs \\ %{}) do
    with :ok <- permit(:create_gateway, user) do
      %Gateway{user_id: user.id}
      |> Gateway.changeset(attrs)
      |> Repo.insert()
    end
  end

  def update_gateway(%User{} = user, %Gateway{} = gateway, attrs) do
    with :ok <- permit(:update_gateway, user, gateway) do
      gateway
      |> Gateway.changeset(attrs)
      |> Repo.update()
    end
  end

  def delete_gateway(%User{} = user, %Gateway{} = gateway) do
    with :ok <- permit(:delete_gateway, user, gateway) do
      Repo.delete(gateway)
    end
  end

  def change_gateway(%Gateway{} = gateway, attrs \\ %{}) do
    Gateway.changeset(gateway, attrs)
  end

  def set_gateway_online(gateway_id, online?) do
    Repo.update_all(from(g in Gateway, where: g.id == ^gateway_id), set: [online: online?])

    Clickr.PubSub.broadcast(
      gateways_topic(),
      {:gateway_online_changed, %{gateway_id: gateway_id, online: online?}}
    )
  end

  def gateways_topic(), do: "gateways"

  def list_devices(%User{} = user, opts \\ []) do
    Device
    |> Bodyguard.scope(user)
    |> Repo.all()
    |> _preload(opts[:preload])
  end

  def get_device!(%User{} = user, id, opts \\ []) do
    Device
    |> Bodyguard.scope(user)
    |> Repo.get!(id)
    |> _preload(opts[:preload])
  end

  def create_device(%User{} = user, attrs \\ %{}) do
    changeset = Device.changeset(%Device{}, attrs)

    with :ok <- permit(:create_device, user, Ecto.Changeset.apply_changes(changeset)) do
      Repo.insert(changeset)
    end
  end

  def update_device(%User{} = user, %Device{} = device, attrs) do
    with :ok <- permit(:update_device, user, Repo.preload(device, :gateway)) do
      device
      |> Device.changeset(attrs)
      |> Repo.update()
    end
  end

  def delete_device(%User{} = user, %Device{} = device) do
    with :ok <- permit(:delete_device, user, Repo.preload(device, :gateway)) do
      Repo.delete(device)
    end
  end

  def upsert_devices(%User{} = user, %Gateway{id: gid} = gateway, attrs) do
    with :ok <- permit(:upsert_devices, user, gateway) do
      delete_query = from(d in Device, where: d.gateway_id == ^gateway.id)
      now = DateTime.utc_now() |> DateTime.truncate(:second)

      default_attrs = %{
        deleted: false,
        gateway_id: gid,
        inserted_at: now,
        updated_at: now
      }

      attrs = Enum.map(attrs, &Map.merge(&1, default_attrs))

      Ecto.Multi.new()
      |> Ecto.Multi.update_all(:soft_delete, delete_query, set: [deleted: true])
      |> Ecto.Multi.insert_all(:insert, Device, attrs,
        on_conflict: {:replace, [:updated_at, :name, :deleted]},
        conflict_target: [:id]
      )
      |> Repo.transaction()
    end
  end

  def change_device(%Device{} = device, attrs \\ %{}) do
    Device.changeset(device, attrs)
  end

  def list_buttons(%User{} = user, opts \\ []) do
    Button
    |> Bodyguard.scope(user)
    |> Repo.all()
    |> _preload(opts[:preload])
  end

  def get_button!(%User{} = user, id, opts \\ []) do
    Button
    |> Bodyguard.scope(user)
    |> Repo.get!(id)
    |> _preload(opts[:preload])
  end

  def create_button(%User{} = user, attrs \\ %{}) do
    changeset = Button.changeset(%Button{}, attrs)

    with :ok <- permit(:create_button, user, Ecto.Changeset.apply_changes(changeset)) do
      Repo.insert(changeset)
    end
  end

  def update_button(%User{} = user, %Button{} = button, attrs) do
    with :ok <- permit(:update_button, user, Repo.preload(button, device: :gateway)) do
      button
      |> Button.changeset(attrs)
      |> Repo.update()
    end
  end

  def delete_button(%User{} = user, %Button{} = button) do
    with :ok <- permit(:delete_button, user, Repo.preload(button, device: :gateway)) do
      Repo.delete(button)
    end
  end

  def change_button(%Button{} = button, attrs \\ %{}) do
    Button.changeset(button, attrs)
  end

  def button_click_topic(%{user_id: uid}), do: "devices.button_click/user:#{uid}"

  def broadcast_button_click(
        %User{id: uid},
        %{button_id: _, device_id: _, gateway_id: _} = attrs,
        %Ecto.Multi{} = upserts \\ Ecto.Multi.new()
      ) do
    attrs = Map.put(attrs, :user_id, uid)
    Clickr.PubSub.broadcast(button_click_topic(attrs), {:button_clicked, upserts, attrs})
  end

  def keyboard_parse_event(%{user_id: _, key: _} = attrs), do: Keyboard.parse_event(attrs)

  def keyboard_get_gateway(%User{} = user) do
    Gateway
    |> Bodyguard.scope(user)
    |> where([g], g.user_id == ^user.id and g.type == :keyboard)
    |> Repo.one()
  end

  def zigbee2mqtt_get_gateway(%User{} = user, %{gateway_id: gid}, opts \\ []) do
    Gateway
    |> Bodyguard.scope(user)
    |> where([g], g.id == ^gid and g.type == :zigbee2mqtt)
    |> Repo.one()
    |> _preload(opts[:preload])
  end

  defp where_ids(query, nil), do: query
  defp where_ids(query, ids), do: where(query, [x], x.id in ^ids)

  defp where_online(query, nil), do: query
  defp where_online(query, online), do: where(query, [x], x.online == ^online)

  defp permit(action, user, params \\ []),
    do: Bodyguard.permit(__MODULE__, action, user, params)

  defp _preload(nil, _), do: nil
  defp _preload(input, nil), do: input
  defp _preload(input, args), do: Repo.preload(input, args)
end
