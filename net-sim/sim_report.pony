trait SimReport
  fun name(): String
  fun keys(sim: Simulator ref): Array[String] iso^
  fun apply(sim: Simulator ref): String iso^
