defmodule Ogutan.Repo do
  use Ecto.Repo,
    otp_app: :ogutan,
    adapter: Ecto.Adapters.Postgres
end
