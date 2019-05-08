actor Server is Node
  let _sim: Simulator
  let _name: String
  let _stats: SimStats

  new create(sim: Simulator, name: String, stats: SimStats) =>
    _sim = sim
    _name = name
    _stats = stats

  be receive(at: U64, msg: NodeMsg val) =>
    _sim.log("received ping!", _name)
    _stats.counter_inc(_name + ".packets_in", 1)
    send([NodeMsg(_name, msg.src, Pong)])

  be tick(at: U64) =>
    _sim.tock(_name, [])

  fun ref send(msgs: Array[NodeMsg val] iso) =>
    _stats.counter_inc(_name + ".packets_out", msgs.size().i64())
    _sim.send(consume msgs)
