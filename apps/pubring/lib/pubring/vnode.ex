defmodule Pubring.Vnode do
  @behaviour :riak_core_vnode
  require Logger

  def start_vnode(partition) do
    :riak_core_vnode_master.get_vnode_pid(partition, __MODULE__)
  end

  def init([partition]) do
    db = :ets.new(__MODULE__, [:bag])
    {:ok, %{db: db, partition: partition}}
  end

  def handle_command(:ping, _sender, %{partition: part} = state) do
    Logger.warn("got a ping request!! woohoO!'")
    {:reply, {:pong, part}, state}
  end

  def handle_command({:subscribe, pid, topic}, _sender, %{db: db} = state) do
    Logger.warn("subscribe #{inspect pid} to #{inspect topic}")
    result = :ets.insert(db, {topic, pid})
    {:reply, result, state}
  end

  def handle_command({:unsubscribe, pid, topic}, _sender, %{db: db} = state) do
    Logger.warn("UNsubscribe #{inspect pid} from #{inspect topic}")
    result = :ets.match_delete(db, {topic, pid})
    {:reply, result, state}
  end

  def handle_command({:broadcast, topic, msg}, _sender, %{db: db} = state) do
    Logger.warn("broadcast #{inspect msg} to #{inspect topic}")
    :ets.foldl(fn ({topic, pid}, acc_in) -> send(pid, msg) end, [], db)
    {:reply, :ok, state}
  end

  def handle_command(message, _sender, state) do
    Logger.warn("weird command? #{inspect([message, state])}")
    {:reply, {:pong, state}, state}
  end

  def handle_handoff_command(message, _sender, state) do
    Logger.warn("unhandled handoff command: #{inspect(message)}")
    {:noreply, state}
  end

  def handoff_starting(_target_node, state) do
    {true, state}
  end

  def handoff_cancelled(state) do
    Logger.warn("handoff cancelled :( #{inspect(state)}")
    {:ok, state}
  end

  def handoff_finished(_target_node, state) do
    Logger.warn("handoff finished! #{inspect(state)}")
    {:ok, state}
  end

  def handle_handoff_data(data, state) do
    Logger.warn("got some handoff data #{ inspect data }")
    {:reply, :ok, state}
  end

  def encode_handoff_item(object_name, object_value) do
    Logger.warn("encoding a handoff item#{inspect([object_name, object_value])}")
    ""
  end

  def is_empty(state) do
    Logger.warn("checking for emptiness")
    {true, state}
  end

  def delete(%{db: db} = state) do
    Logger.warn("delete the vnode")
    :ets.delete(db)
    {:ok, state}
  end

  def handle_coverage(req, key_spaces, sender, state) do
    Logger.warn("handle coverage #{inspect([req, key_spaces, sender, state])}")
    {:stop, :not_implemented, state}
  end

  def handle_exit(pid, reason, state) do
    Logger.warn("handle exit #{inspect([pid, reason, state])}")
    {:noreply, state}
  end

  def terminate(reason, state) do
    Logger.warn("terminate #{inspect([reason, state])}")
    :ok
  end
end
