trait SimReport
  fun filename(): String
  fun keys(sim: Simulator ref): Array[String] iso^
  fun apply(sim: Simulator ref): String iso^
