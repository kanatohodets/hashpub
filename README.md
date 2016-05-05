# Hashpub

A small example of using `riak_core` as a pubsub adapter for Phoenix Channels.

The messages/subscriptions are hashed and distributed by topic, so this
approach would work best for applications with large numbers of topics, each
with fairly uniform resource requirements. One cool trick you could do with
this approach would be to manage some state for the topic in the vnode: this
could be as simple as chat history, or as complex as the game simulation state.

Currently does not implement handoff or multi-read/multi-write.

## To run:

(in 3 terminals)
    
    MIX_ENV=dev_a iex --name dev_a@127.0.0.1 -S mix phoenix.server
    MIX_ENV=dev_b iex --name dev_b@127.0.0.1 -S mix phoenix.server
    MIX_ENV=dev_c iex --name dev_c@127.0.0.1 -S mix phoenix.server

Then, in 2 out of the 3:

    :riak_core.join('dev_b@127.0.0.1')

(I have TODO to implement the console and some bash to both of these steps easier)

You'll see messages about vnode handoff, and in a little while you'll have
a running `riak_core` cluster to manage your Phoenix PubSub.
    
Next, hit the Phoenix applications available on `localhost:4000`, `4001`, or
`4002`. Type some messages into the box, observe that they're hashed and sent
to one of the 3 cluster members.
