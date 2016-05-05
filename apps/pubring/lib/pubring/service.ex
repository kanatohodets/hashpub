defmodule Pubring.Service do
  require Logger

  def ping do
    doc_idx = :riak_core_util.chash_key({"ping", :erlang.term_to_binary(:os.timestamp())})
    pref_list = :riak_core_apl.get_primary_apl(doc_idx, 1, Pubring.Service)
    Logger.warn("pref list: #{inspect(pref_list)}")
    [{index_node, _type}] = pref_list
    # riak core appends "_master" to Picor.Vnode.
    :riak_core_vnode_master.sync_spawn_command(index_node, :ping, Pubring.Vnode_master)
  end

  def subscribe(pid, topic, opts) do
    index_node = get_topic_index_node(topic)
    :riak_core_vnode_master.sync_spawn_command(index_node, {:subscribe, pid, topic}, Pubring.Vnode_master)
  end

  def unsubscribe(pid, topic) do
    index_node = get_topic_index_node(topic)
    :riak_core_vnode_master.sync_spawn_command(index_node, {:unsubscribe, pid, topic}, Pubring.Vnode_master)
  end

  def broadcast(topic, message) do
    index_node = get_topic_index_node(topic)
    :riak_core_vnode_master.sync_spawn_command(index_node, {:broadcast, topic, message}, Pubring.Vnode_master)
  end

  defp get_topic_index_node(topic) do
    doc_idx = :riak_core_util.chash_key({"topic", topic})
    pref_list = :riak_core_apl.get_primary_apl(doc_idx, 1, Pubring.Service)
    Logger.warn("pref list: #{inspect(pref_list)}")
    [{index_node, _type}] = pref_list
    index_node
  end
end
