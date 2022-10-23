defmodule Clickr.Mailer do
  use Boundary, exports: [], deps: []

  use Swoosh.Mailer, otp_app: :clickr
end
