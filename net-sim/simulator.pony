use "collections"
use "logger"
use "promises"
use "random"

actor Simulator
  let _env: Env
  let logger: Logger[String val]
  let _tick_period: U64 val
  let _events: Array[SimEvent val]
  let _outbox: MinHeap[OutgoingNodeMsg] = MinHeap[OutgoingNodeMsg](10)
  let sim_time: SimTime
  let nodes: Map[NodeId, Node tag] = Map[NodeId, Node tag]
  let defects: Map[NodeId, Array[NetworkDefect]] =
    Map[NodeId, Array[NetworkDefect]]
  let reports: Array[SimReport val] val
  let stats: SimStats tag

  var _tick: U64 = 0
  var running: Bool = true
  var _waiting: USize = 0
  var rng: Random = Rand

  new create(tick_period: U64, env: Env, logger': Logger[String val],
    events: Array[SimEvent val] iso, sim_time': SimTime,
    reports': Array[SimReport val] val = [])
  =>
    _env = env
    _tick_period = tick_period
    sim_time = sim_time'
    logger = logger'
    reports = reports'
    stats = SimStats(_tick_period, logger)

    _events = consume events
    _events.reverse_in_place() // Use Array like a stack
    tick()

  be tick() =>
    //_log("sim: _tick=" + _tick.string())
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
        if reports.size() > 0 then
          let p = Promise[Array[Map[String, I64] val] val]
          p.next[None]({(s)(sim: Simulator tag = this) => sim._gen_reports(s)})
          stats.stats(p)
        else
          let p = Promise[String val]
          p.next[None]({(s: String val)(_env) => _env.out.write(s)})
          stats.to_string(p)
        end
      end
    end

  be send(msgs: Array[NodeMsg val] iso) =>
    queue_msgs(consume msgs)

  fun ref queue_msgs(msgs': Array[NodeMsg val] iso) =>
    let msgs: Array[NodeMsg val] ref = consume msgs'
    for msg in msgs.values() do
      _queue_msg(msg)
    end

  fun ref _queue_msg(msg: NodeMsg val) =>
    let out_msg = OutgoingNodeMsg((_tick + 1) * _tick_period, msg)

    for defect in defects.get_or_else(msg.src, []).values() do
      defect(out_msg, this)
    end

    for defect in defects.get_or_else(msg.dst, []).values() do
      defect(out_msg, this)
    end

    if out_msg.drop then
      return
    else
      _outbox.push(out_msg)
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

  be _gen_reports(data: Array[Map[String, I64] val] val) =>
    let out: String iso = recover String end

    for report in reports.values() do
      let keys: Array[String] = report.keys(this)
      for k in keys.values() do
        out.append(k)
        out.push('\t')
      end
      try out.>pop()?.>push('\n') end
      for map in data.values() do
        for k in keys.values() do
          if map.contains(k) then
            try out.append(map(k)?.string()) end
          else
            out.push('0')
          end
          out.push('\t')
        end
        try out.>pop()?.>push('\n') end
      end
      out.append(report(this))
    end

    _env.out.print(consume out)

  fun _log(msg: String): Bool =>
    logger.log(msg)
