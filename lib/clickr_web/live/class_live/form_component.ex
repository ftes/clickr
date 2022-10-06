defmodule ClickrWeb.ClassLive.FormComponent do
  use ClickrWeb, :live_component

  alias Clickr.Classes

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage class records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="class-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :name}} type="text" label="name" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Class</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{class: class} = assigns, socket) do
    changeset = Classes.change_class(class)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"class" => class_params}, socket) do
    changeset =
      socket.assigns.class
      |> Classes.change_class(class_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"class" => class_params}, socket) do
    save_class(socket, socket.assigns.action, class_params)
  end

  defp save_class(socket, :edit, class_params) do
    case Classes.update_class(socket.assigns.class, set_user_id(socket, class_params)) do
      {:ok, _class} ->
        {:noreply,
         socket
         |> put_flash(:info, "Class updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_class(socket, :new, class_params) do
    case Classes.create_class(set_user_id(socket, class_params)) do
      {:ok, _class} ->
        {:noreply,
         socket
         |> put_flash(:info, "Class created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp set_user_id(socket, params), do: Map.put(params, "user_id", socket.assigns.current_user.id)
end
