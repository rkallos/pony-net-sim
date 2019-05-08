use "logger"
use "collections"
use "promises"

actor SimStats
  let logger: Logger[String val]
  let metrics: Array[(U64, Map[String, I64])] =
    Array[(U64, Map[String, I64])]
  var cur: Map[String, I64] = Map[String, I64]
  var _at: U64 = 0

  new create(logger': Logger[String val]) =>
    logger = logger'

  be tick(at: U64) =>
    let old_at = _at = at
    metrics.push((old_at, cur))
    cur = cur.clone()

  be gauge_set(name: String, value: I64) =>
    cur(name) = value

  be counter_inc(name: String, value: I64) =>
    try cur.upsert(name, value, {(prev, delta) => prev + delta})? end

  be to_string(p: Promise[String val]) =>
    let keys = Array[String](cur.size() + 1)
    for key in cur.keys() do
        keys.push(key)
    end

    let out: String iso = recover String end
    out.append("time\t")
    for k in keys.values() do
      out.append(k)
      out.push('\t')
    end
    try out.>pop()?.>push('\n') end

    for pair in metrics.values() do
      (let t: U64, let map: Map[String, I64]) = pair
      out.append(t.string())
      out.push('\t')
      for k in keys.values() do
        if map.contains(k) then
          try out.append(map(k)?.string()) end
        else
          out.push('0')
        end
        out.push('\t')
      end
      try out.>pop()?.>push('\n') end
    end
    p(consume out)
