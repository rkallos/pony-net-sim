primitive DelaySend
primitive DelayRecv
primitive DropSend
primitive DropFrom

type _NetworkDefectKind is
( DelaySend
| DelayRecv
| DropSend
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

  new val drop_send(amt': U64) =>
    kind = DropSend
    amt = amt'
    node = ""

  new val drop_from(src: NodeId) =>
    kind = DropFrom
    amt = 0
    node = src

  fun apply(msg: OutgoingNodeMsg ref, sim: Simulator ref) =>
    match kind
    | DelaySend =>
      if msg.msg.dst.contains(node) then
        msg.ts = msg.ts + amt
      end
    | DelayRecv =>
      if msg.msg.src.contains(node) then
        msg.ts = msg.ts + amt
      end
    | DropSend =>
      if (sim.rng.next() % 100) >= amt then
        msg.drop = true
      end
    | DropFrom =>
      if msg.msg.dst.contains(node) then
        msg.drop = true
      end
    end
