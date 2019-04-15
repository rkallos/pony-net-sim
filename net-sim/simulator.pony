use "collections"
use "logger"
use "promises"

actor Simulator
  let _env: Env
  let logger: Logger[String val]
  let _tick_period: U64 val
  let _events: Array[SimEvent val]
  let _outbox: MinHeap[OutgoingNodeMsg val] = MinHeap[OutgoingNodeMsg val](10)
  let nodes: Map[NodeId, Node tag] = Map[NodeId, Node tag]
  let stats: Stats tag

  var _tick: U64 = 0
  var running: Bool = true
  var _waiting: USize = 0

  new create(tick_period: U64, env: Env, logger': Logger[String val],
    events: Array[SimEvent val] iso)
  =>
    _env = env
    _tick_period = tick_period
    logger = logger'
    stats = Stats(logger)

    _events = consume events
    _events.reverse_in_place() // Use Array like a stack
    tick()

  be tick() =>
    _log("sim: _tick=" + _tick.string())
    try
      process_events()?
    else
      logger(Error) and _log("sim: error processing events")
    end

    let now = _tick * _tick_period
    if (now > 0) then stats.tick(now) end

    try
      while _outbox.peek()?.ts <= now do
        let msg = _outbox.pop()?.msg
        nodes(msg.dst)?.receive(now, msg)
      end
    end

    for node in nodes.values() do
      node.tick(now)
    end

    _waiting = nodes.size()

  be tock(id: NodeId, msgs: Array[NodeMsg val] iso) =>
    queue_msgs(consume msgs)
    _waiting = _waiting - 1
    if (_waiting == 0) then
      if running then
        _tick = _tick + 1
        tick()
      else
        let now = _tick * _tick_period
        stats.tick(now)
        let p = Promise[String val]
        p.next[None]({(s: String val)(_env) => _env.out.write(s)})
        stats.to_string(p)
      end
    end

  be send(msgs: Array[NodeMsg val] iso) =>
    queue_msgs(consume msgs)

  fun ref queue_msgs(msgs: Array[NodeMsg val] iso) =>
    let next_ts = (_tick + 1) * _tick_period
    for msg in (consume msgs).values() do
      // TODO: Add network defects
      _outbox.push(OutgoingNodeMsg(next_ts, msg))
    end

  be log(msg: String, node: String = "sim") =>
    let str = recover
      String((node.size() + msg.size()) + 2)
      .>append(node)
      .>append(": ")
      .>append(msg)
    end
    _log(consume str)

  fun ref process_events()? =>
    while _events.size() > 0 do
      let now_ts: U64 = _tick * _tick_period
      if _events(_events.size() - 1)?.ts() <= now_ts then
        let event = _events.pop()?
        event(this)?
      else
        return
      end
    end

  fun _log(msg: String): Bool =>
    logger.log(msg)
