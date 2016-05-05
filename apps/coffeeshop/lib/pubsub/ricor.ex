defmodule Phoenix.PubSub.Ricor do
  require Logger
  use Supervisor

  def start_link(name, opts) do
    supervisor_name = Module.concat(name, Supervisor)
    Supervisor.start_link(__MODULE__, [name, opts], name: supervisor_name)
  end

  def init([server, opts]) do
    ^server = :ets.new(server, [:set, :named_table, read_concurrency: true])
    true = :ets.insert(server, {:subscribe, Phoenix.PubSub.RicorServer, []})
    true = :ets.insert(server, {:unsubscribe, Phoenix.PubSub.RicorServer, []})
    true = :ets.insert(server, {:broadcast, Phoenix.PubSub.RicorServer, []})

    Logger.warn("pubsub.ricor init: #{inspect [server, opts]}")
    children = [
      #supervisor(Phoenix.PubSub.LocalSupervisor, [server_name, dispatch_rules]),
      worker(Phoenix.PubSub.RicorServer, [server])
    ]
    supervise(children, strategy: :one_for_one)
  end
end
