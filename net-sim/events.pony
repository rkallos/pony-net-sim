class SimStop is SimEvent
  let _ts: U64

  new val create(ts': U64) =>
    _ts = ts'

  fun apply(sim: Simulator ref) =>
    sim.running = false

  fun ts(): U64 => _ts

class ServerUp is SimEvent
  let _name: NodeId
  let _ts: U64

  new val create(ts': U64, name: NodeId) =>
    _ts = ts'
    _name = name

  fun apply(sim: Simulator ref) =>
    let server: Server = Server(sim, _name, sim.stats)
    sim.log("starting server node named " + _name)
    sim.nodes(_name) = server

  fun ts(): U64 => _ts

class ClientUp is SimEvent
  let _name: NodeId
  let _ts: U64

  new val create(ts': U64, name: NodeId) =>
    _ts = ts'
    _name = name

  fun apply(sim: Simulator ref) =>
    let client = Client(sim, _name, sim.stats)
    sim.log("starting client node named " + _name)
    sim.nodes(_name) = client

  fun ts(): U64 => _ts

primitive Ping
primitive Pong
class PingPong is SimEvent
  let _client: NodeId
  let _server: NodeId
  let _ts: U64

  new val create(ts': U64, client: NodeId, server: NodeId) =>
    _ts = ts'
    _client = client
    _server = server

  fun apply(sim: Simulator ref)? =>
    sim.log("starting pingpong between " +
      _client + " and " + _server +
      " at time " + _ts.string())
    let c = sim.nodes(_client)? as Client
    c.pingpong(_server)

  fun ts(): U64 => _ts
