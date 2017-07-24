defmodule Stravelixm.PageController do
  use Stravelixm.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
