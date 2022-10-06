defmodule ClickrWeb.SubjectLive.FormComponent do
  use ClickrWeb, :live_component

  alias Clickr.Subjects

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage subject records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="subject-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :name}} type="text" label="Name" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Subject</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{subject: subject} = assigns, socket) do
    changeset = Subjects.change_subject(subject)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"subject" => subject_params}, socket) do
    changeset =
      socket.assigns.subject
      |> Subjects.change_subject(subject_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"subject" => subject_params}, socket) do
    save_subject(socket, socket.assigns.action, subject_params)
  end

  defp save_subject(socket, :edit, subject_params) do
    # TODO Check permission

    case Subjects.update_subject(socket.assigns.subject, set_user_id(socket, subject_params)) do
      {:ok, _subject} ->
        {:noreply,
         socket
         |> put_flash(:info, "Subject updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_subject(socket, :new, subject_params) do
    case Subjects.create_subject(set_user_id(socket, subject_params)) do
      {:ok, _subject} ->
        {:noreply,
         socket
         |> put_flash(:info, "Subject created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp set_user_id(socket, params), do: Map.put(params, "user_id", socket.assigns.current_user.id)
end
