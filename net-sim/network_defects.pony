primitive DelaySend
primitive DelayRecv
primitive DropType
primitive DropFrom

type NetworkDefectKind is
( (DelaySend, U64)
| (DelayRecv, U64)
| (DropFrom, NodeId)
)

class val NetworkDefect
  var kind: (DelaySend | DelayRecv | DropFrom) = DropFrom
  var amt: U64 = 0
  var node: NodeId = ""

  new val create(defect: NetworkDefectKind) =>
    match defect
    | (DelaySend, let t: U64) =>
      kind = DelaySend
      amt = t
    | (DelayRecv, let t: U64) =>
      kind = DelayRecv
      amt = t
    | (DropFrom, let n: NodeId) =>
      kind = DropFrom
      node = n
    end
