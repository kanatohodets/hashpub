defmodule Phoenix.PubSub.RicorServer do
  use GenServer
  require Logger

  def start_link(server_name) do
    GenServer.start_link(__MODULE__, server_name, name: server_name)
  end

  def init(server_name) do
    Logger.warn("init PubSub.RicorServer with #{inspect server_name}")
    {:ok, %{}}
  end

  def subscribe(pid, topic, opts) do
    Logger.warn("pubsub subscribe #{inspect [pid, topic, opts]}")
    Pubring.Service.subscribe(pid, topic, opts)
  end

  def unsubscribe(pid, topic) do
    Logger.warn("pubsub unsubscribe #{inspect [pid, topic]}")
    Pubring.Service.unsubscribe(pid, topic)
  end

  def broadcast(pid, topic, message) do
    Logger.warn("pubsub broadcast #{inspect [pid, topic, message]}")
    Pubring.Service.broadcast(topic, message)
  end

  def handle_call(msg, from, state) do
    Logger.warn("ricor server got a call?! #{inspect [msg, from, state]}")
    {:reply, :ok, state}
  end

  def handle_info(msg, from, state) do
    Logger.warn("ricor server got an info?! #{inspect [msg, from, state]}")
    {:noreply, :ok, state}
  end

end
