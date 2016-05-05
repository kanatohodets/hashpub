defmodule Pubring.App do
  use Application

  def start(_type, _args) do
    case Pubring.Sup.start_link() do
      {:ok, pid} ->
        :ok = :riak_core.register([{:vnode_module, Pubring.Vnode}])
        :ok = :riak_core_node_watcher.service_up(Pubring.Service, self)
        {:ok, pid}
      {:error, reason} ->
        {:error, reason}
    end
  end
end
