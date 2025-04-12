defmodule OgutanWeb.GoogleAuth do
  import Plug.Conn

  alias Assent.Strategy.Google

  # http://localhost:4000/auth/google
  def request(conn) do
    Application.get_env(:assent, :google)
    |> Google.authorize_url()
    |> IO.inspect(label: "authorize_url")
    |> case do
      {:ok, %{url: url, session_params: session_params}} ->
        # Session params (used for OAuth 2.0 and OIDC strategies) will be
        # retrieved when user returns for the callback phase
        conn = put_session(conn, :session_params, session_params)

        # Redirect end-user to Google to authorize access to their account
        conn
        |> put_resp_header("location", url)
        |> send_resp(302, "")

      {:error, error} ->
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(
          500,
          "Something went wrong generating the request authorization url: #{inspect(error)}"
        )
    end
  end

  # http://localhost:4000/auth/google/callback
  def callback(conn) do
    # End-user will return to the callback URL with params attached to the
    # request. These must be passed on to the strategy. In this example we only
    # expect GET query params, but the provider could also return the user with
    # a POST request where the params is in the POST body.
    %{params: params} = fetch_query_params(conn)

    # The session params (used for OAuth 2.0 and OIDC strategies) stored in the
    # request phase will be used in the callback phase
    session_params = get_session(conn, :session_params)

    Application.get_env(:assent, :google)
    # Session params should be added to the config so the strategy can use them
    |> Keyword.put(:session_params, session_params)
    |> Google.callback(params)
    |> IO.inspect(label: "callback params")
    |> case do
      {:ok, %{user: user, token: token}} ->
        # Authorization succesful
        IO.inspect({user, token}, label: "user and token")
        user_record = Ogutan.Accounts.get_user_by_email_or_register(user["email"])

        conn
        |> OgutanWeb.UserAuth.log_in_user(user_record)
        |> put_session(:google_user, user)
        |> put_session(:google_user_token, token)
        |> Phoenix.Controller.redirect(to: "/")

      {:error, error} ->
        # Authorizaiton failed
        IO.inspect(error, label: "error")

        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(500, inspect(error, pretty: true))
    end
  end
end
