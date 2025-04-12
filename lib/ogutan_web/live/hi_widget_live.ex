defmodule OgutanWeb.HiWidgetLive do
  use OgutanWeb, :live_view
  on_mount {OgutanWeb.UserAuth, :mount_current_user}

  def render(assigns) do
    if assigns[:current_user] do
      ~H"""
      <div>👋 Hi, {@current_user.email}</div>
      """
    else
      ~H"""
      <div>🤔 Do I know you?</div>
      """
    end
  end
end
