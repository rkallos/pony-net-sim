primitive DelaySend
primitive DelayRecv
primitive DropType
primitive DropFrom

type NetworkDefect is
( (DelaySend, U64)
| (DelayRecv, U64)
| (DropFrom, NodeId)
)
