use "logger"

type NodeId is String val

trait Node
  be receive(at: U64, msg: NodeMsg val)
  be tick(at: U64)

class val NodeMsg
  let src: NodeId
  let dst: NodeId
  let msg: Any val

  new val create(src': NodeId, dst': NodeId, msg': Any val) =>
    src = src'
    dst = dst'
    msg = msg'

class OutgoingNodeMsg is Comparable[OutgoingNodeMsg box]
  var ts: U64
  let msg: NodeMsg val
  var drop: Bool = false

  new create(ts': U64, msg': NodeMsg val) =>
    ts = ts'
    msg = msg'

  fun lt(that: OutgoingNodeMsg box): Bool =>
    ts < that.ts
