defmodule ClickrWeb.Router do
  use ClickrWeb, :router

  import ClickrWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ClickrWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ClickrWeb do
    pipe_through :browser
    get "/", Redirector, to: "/lessons"
  end

  # Other scopes may use custom stacks.
  # scope "/api", ClickrWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:clickr, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/live_dashboard", metrics: ClickrWeb.Telemetry
    end

    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", ClickrWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{ClickrWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", ClickrWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [
        {ClickrWeb.UserAuth, :ensure_authenticated},
        {ClickrWeb.GatewayPresence, :load_and_subscribe}
      ] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email

      live "/classes", ClassLive.Index, :index
      live "/classes/new", ClassLive.Index, :new
      live "/classes/:id/edit", ClassLive.Index, :edit
      live "/classes/:id", ClassLive.Show, :show
      live "/classes/:id/show/edit", ClassLive.Show, :edit

      live "/rooms", RoomLive.Index, :index
      live "/rooms/new", RoomLive.Index, :new
      live "/rooms/:id/edit", RoomLive.Index, :edit
      live "/rooms/:id", RoomLive.Show, :show
      live "/rooms/:id/show/edit", RoomLive.Show, :edit

      live "/gateways", GatewayLive.Index, :index
      live "/gateways/new", GatewayLive.Index, :new
      live "/gateways/:id/edit", GatewayLive.Index, :edit
      live "/gateways/:id", GatewayLive.Show, :show
      live "/gateways/:id/show/edit", GatewayLive.Show, :edit

      live "/devices", DeviceLive.Index, :index
      live "/devices/new", DeviceLive.Index, :new
      live "/devices/:id/edit", DeviceLive.Index, :edit
      live "/devices/:id", DeviceLive.Show, :show
      live "/devices/:id/show/edit", DeviceLive.Show, :edit

      live "/buttons", ButtonLive.Index, :index
      live "/buttons/new", ButtonLive.Index, :new
      live "/buttons/:id/edit", ButtonLive.Index, :edit
      live "/buttons/:id", ButtonLive.Show, :show
      live "/buttons/:id/show/edit", ButtonLive.Show, :edit

      live "/button_plans", ButtonPlanLive.Index, :index
      live "/button_plans/new", ButtonPlanLive.Index, :new
      live "/button_plans/:id/edit", ButtonPlanLive.Index, :edit
      live "/button_plans/:id", ButtonPlanLive.Show, :show
      live "/button_plans/:id/show/edit", ButtonPlanLive.Show, :edit

      live "/students", StudentLive.Index, :index
      live "/students/new", StudentLive.Index, :new
      live "/students/:id/edit", StudentLive.Index, :edit
      live "/students/:id", StudentLive.Show, :show
      live "/students/:id/show/edit", StudentLive.Show, :edit

      live "/subjects", SubjectLive.Index, :index
      live "/subjects/new", SubjectLive.Index, :new
      live "/subjects/:id/edit", SubjectLive.Index, :edit
      live "/subjects/:id", SubjectLive.Show, :show
      live "/subjects/:id/show/edit", SubjectLive.Show, :edit

      live "/seating_plans", SeatingPlanLive.Index, :index
      live "/seating_plans/new", SeatingPlanLive.Index, :new
      live "/seating_plans/:id/edit", SeatingPlanLive.Index, :edit
      live "/seating_plans/:id", SeatingPlanLive.Show, :show
      live "/seating_plans/:id/show/edit", SeatingPlanLive.Show, :edit

      live "/lessons", LessonLive.Index, :index
      live "/lessons/new", LessonLive.Index, :new
      live "/lessons/:id/edit", LessonLive.Index, :edit
      live "/lessons/:id", LessonLive.Show, :show
      live "/lessons/:id/show/edit", LessonLive.Show, :edit
      live "/lessons/:id/router", LessonLive.Router, :show
      live "/lessons/:id/started", LessonLive.RollCall, :started
      live "/lessons/:id/roll_call", LessonLive.RollCall, :roll_call
      live "/lessons/:id/active", LessonLive.Question, :active
      live "/lessons/:id/question", LessonLive.Question, :question
      live "/lessons/:id/ended", LessonLive.Ended, :ended
      live "/lessons/:id/graded", LessonLive.Ended, :graded

      live "/grades", GradeLive.Index, :index
      live "/grades/:id", GradeLive.Show, :show
    end
  end

  scope "/", ClickrWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{ClickrWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
