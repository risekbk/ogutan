defmodule OgutanWeb.GoogleAuthController do
  use OgutanWeb, :controller
  alias OgutanWeb.GoogleAuth

  def request(conn, _params) do
    GoogleAuth.request(conn)
  end

  def callback(conn, _params) do
    GoogleAuth.callback(conn)
  end
end
