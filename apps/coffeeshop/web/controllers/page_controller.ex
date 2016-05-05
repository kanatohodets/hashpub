defmodule Coffeeshop.PageController do
  use Coffeeshop.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
