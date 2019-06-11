class val SimTime
  let period: U64

  new val create(period': U64) =>
    period = period'

  fun apply(tick: U64): U64 =>
    """
    Given a tick number, returns the number of milliseconds that have elapsed
    since the beginning of the simulation.
    """
    tick * period

  fun mins(n: U64): U64 =>
    """
    Given a time in minutes since the beginning of a simulation, returns the
    tick number corresponding to that moment
    """
    ((n * 60) * 1000) / period

  fun secs(n: U64): U64 =>
    """
    Given a time in seconds since the beginning of a simulation, returns the
    tick number corresponding to that moment
    """
    (n * 1000) / period

  fun msecs(n: U64): U64 =>
    """
    Given a time in milliseconds since the beginning of a simulation, returns
    the tick number corresponding to that moment
    """
    n / period
