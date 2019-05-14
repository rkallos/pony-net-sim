primitive DelaySend
primitive DelayRecv
primitive DropType
primitive DropFrom

type _NetworkDefectKind is
( DelaySend
| DelayRecv
| DropFrom
)

class val NetworkDefect
  let kind: _NetworkDefectKind
  let amt: U64
  let node: NodeId

  new val delay_send(amt': U64, dst: NodeId) =>
    kind = DelaySend
    amt = amt'
    node = dst

  new val delay_recv(amt': U64, src: NodeId) =>
    kind = DelayRecv
    amt = amt'
    node = src

  new val drop_from(src: NodeId) =>
    kind = DropFrom
    amt = 0
    node = src

  fun apply(msg: OutgoingNodeMsg ref, sim: Simulator ref) =>
    match kind
    | DelaySend =>
      msg.ts = msg.ts + amt
    | DelayRecv =>
      msg.ts = msg.ts + amt
    | DropFrom =>
      if msg.msg.dst == node then
        msg.drop = true
      end
    end
