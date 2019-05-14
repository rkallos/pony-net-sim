use "logger"

class val SimConfig
  """
  A container class comprised of some of the objects created by Simulator that
  might be of interest to any other objects created by the Simulator
  """
  let sim: Simulator tag
  let logger: Logger[String val]
  let stats: SimStats
  let time: SimTime

  new val create(sim': Simulator tag, logger': Logger[String val],
    stats': SimStats, time': SimTime)
  =>
  sim = sim'
  logger = logger'
  stats = stats'
  time = time'
