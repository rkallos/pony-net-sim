trait Simulation
  fun name(): String
  fun reports(): Array[SimReport val] val
  fun events(simtime: SimTime): Array[SimEvent val] iso^
