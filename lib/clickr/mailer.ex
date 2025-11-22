defmodule Clickr.Mailer do
  @moduledoc false
  use Boundary, exports: [], deps: []
  use Swoosh.Mailer, otp_app: :clickr
end
