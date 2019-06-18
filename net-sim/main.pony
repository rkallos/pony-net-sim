use "cli"
use "logger"

primitive _SimLogFormatter is LogFormatter
  // This is the same as env.err.print right now, but it doesn't have to be
  fun apply(msg: String, loc: SourceLoc): String => msg

actor Main
  new create(env: Env) =>
    let cs =
      try
        CommandSpec.leaf("sim", "pacingd simulator", [
        OptionSpec.u64("tick-period", "Milliseconds per simulator tick. Must be under 1000"
          where short' = 't', default' = U64(10))
        OptionSpec.u64("log-level", "Log level. 0 = Fine, 1 = Info, 2 = Warn, 3 = Error"
          where short' = 'l', default' = U64(0))
        ], [])? .> add_help()?
      else
        env.exitcode(-1) // some kind of coding error
        return
      end

    let cmd =
      match CommandParser(cs).parse(env.args, env.vars)
      | let c: Command => c
      | let ch: CommandHelp =>
        ch.print_help(env.out)
        env.exitcode(0)
        return
      | let se: SyntaxError =>
        env.out.print(se.string())
        env.exitcode(1)
        return
      end

    let tick_period: U64 = cmd.option("tick-period").u64()

    if tick_period >= 1000 then
      env.err.print("tick-period must be less than 1000")
      env.exitcode(1)
      return
    end

    let log_level = match cmd.option("log-level").u64()
    | 0 => Fine
    | 1 => Info
    | 2 => Warn
    | 3 => Error
    else
      Error
    end

    let logger = StringLogger(log_level, env.err, _SimLogFormatter)

    let events: Array[SimEvent val] iso = recover iso
    [
    ServerUp(0, "server1")
    ClientUp(0, "client1")
    PingPong(0, "client1", "server1")
    SimStop(100)
    ]
    end

    let s = Simulator(env, logger, consume events, tick_period)
