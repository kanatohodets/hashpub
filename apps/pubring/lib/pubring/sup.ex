defmodule Pubring.Sup do
  use Supervisor

  def start_link do
    # riak_core appends _sup to the application name
    Supervisor.start_link(__MODULE__, [], [name: :pubring_sup])
  end

  def init(_args) do
    # riak_core appends _master to 'Pubring.Vnode'
    children = [
      worker(:riak_core_vnode_master, [Pubring.Vnode], id: Pubring.Vnode_master_worker)
      #supervisor(Pubring.OpFSM.Sup, []) # no opFSM for now
    ]

    supervise(children, strategy: :one_for_one, max_restarts: 5, max_seconds: 10)
  end
end
