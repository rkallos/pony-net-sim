trait SimEvent
  fun ts(): U64
  fun apply(sim: Simulator ref): None ?
