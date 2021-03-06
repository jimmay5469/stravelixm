defmodule Stravelixm.Router do
  use Stravelixm.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Stravelixm do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/token_exchange", PageController, :token_exchange
    get "/logout", PageController, :logout
  end

  # Other scopes may use custom stacks.
  # scope "/api", Stravelixm do
  #   pipe_through :api
  # end
end
