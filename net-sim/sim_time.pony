class val SimTime
  let period: U64

  new val create(period': U64) =>
    period = period'

  fun mins(n: U64): U64 =>
    ((n * 60) * 1000) / period

  fun secs(n: U64): U64 =>
    (n * 1000) / period

  fun msecs(n: U64): U64 =>
    n / period
