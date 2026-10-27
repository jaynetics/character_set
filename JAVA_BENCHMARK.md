# Initial JRuby Java backend measurements

Measured on 2026-10-26. These are development measurements of the new backend
against the existing Ruby fallback, using the same public `CharacterSet` API.
They are not comparisons with CRuby+C or a claim about every workload.

## Environment and procedure

- JRuby 10.1.1.0, Ruby compatibility version 4.0.0, commit `aaa95d57e1`.
- Temurin OpenJDK 25.0.5+8-LTS, standard JRuby launcher options, no explicit GC tuning.
- macOS 27.0.1, aarch64, 10 processors reported to the JVM.
- Three independent JVMs per backend; backend execution order alternated between rounds.
- Two seconds of warmup and at least one second of measurement per case.
- Fixtures constructed outside timed loops; operation results checked before and after timing.
- The fallback ran from a temporary library copy with the JAR removed. It used
  `CharacterSet`, avoiding the operand-adaptation overhead of `CharacterSet::Pure`.
- No other test or benchmark jobs ran concurrently with these six measurements.

Reproduce with a configured full JDK and JRuby:

```sh
WARMUP=2 TIME=1 RUNS=3 \
  CASES=membership,count_mixed,keep_mixed,cover_first,union_dense,merge_reset \
  bundle exec rake benchmark:java > java-benchmark.json
```

The command emits individual process measurements, environment details, and
summary statistics as JSON. The normal benchmark defaults use a longer
10-second warmup and 3-second measurement period. The shorter settings above
were used for this initial implementation check.

## Throughput

All rates are operations per second. Ranges are minimum to maximum across the
three independent processes; speedups compare medians.

| Case | Fallback median | Fallback range | Java median | Java range | Speedup |
| --- | ---: | ---: | ---: | ---: | ---: |
| Integer membership | 25,066,864 | 23,483,580–25,964,535 | 30,622,655 | 29,152,794–31,417,142 | 1.22× |
| Count mixed UTF-8 | 1,784 | 1,783–1,855 | 47,923 | 47,629–48,152 | 26.87× |
| Keep selected mixed UTF-8 | 1,738 | 1,683–1,774 | 30,435 | 30,351–30,688 | 17.52× |
| Early-exit coverage | 2,514,312 | 2,164,553–2,606,252 | 61,635,876 | 60,968,229–62,998,465 | 24.51× |
| Dense union and size | 237 | 232–237 | 696,001 | 692,433–698,380 | 2,934× |
| Merge, subtract, and size | 1,105 | 1,076–1,196 | 4,169,106 | 3,993,551–4,173,014 | 3,774× |

Workloads:

- Membership checks integer `97` in a four-member set.
- Mixed input is `'ab cd ü 😋 ' * 1024`: 14,336 UTF-8 bytes. Counting and keeping
  use the set containing `a`, `b`, `ü`, and `😋`; the retained result is 8,192 bytes.
- Coverage uses that same set and input; it returns false at the first space,
  the third codepoint. Its benchmark identifier is `cover_first`.
- Dense union combines `0..0xFFFF` with `0x8000..0x1FFFF` and reads the result's size.
- Merge/reset merges `0x4000..0x7FFF` into `0..0x3FFF`, subtracts those inserted
  values again, and reads the remaining size. Every timed iteration performs
  real mutation and restores the starting contents.

The large algebra gains reflect bulk bitmap operations replacing Ruby Hash
iteration and allocation. The coverage gain includes eliminating the Ruby
enumeration and transcoding setup performed by the fallback. Neither result
establishes a corresponding advantage over a different native implementation.

## Allocation observations

Median bytes allocated per operation, obtained from the JVM's thread allocation
counter. These figures include Ruby call and benchmark harness overhead; they
measure allocation volume, not retained heap size or peak process memory.

| Case | Fallback bytes/op | Java bytes/op |
| --- | ---: | ---: |
| Integer membership | 24.6 | 24.6 |
| Count mixed UTF-8 | 770,993 | 24.6 |
| Keep selected mixed UTF-8 | 797,121 | 14,425 |
| Early-exit coverage | 528.6 | 0.6 |
| Dense union and size | 5,636,835 | 24,777 |
| Merge, subtract, and size | 1,442,273 | 48.6 |

Counting inspects the complete mixed string while allocating approximately one
Ruby integer result per call. Filtering allocates an output buffer on the first
removed character; its capacity is currently bounded by input byte length and
can exceed the final result's byte length.

## Limits and follow-up

These short runs establish a useful improvement over the fallback on the selected
cases. Release performance validation should also run the longer default settings,
the remaining ASCII/UTF-16/absent-match/unchanged-output cases, and the broader
size, density, and set-shape matrix in `JAVA_BACKEND_PLAN.md`.

This report does not measure first-load latency, retained heap, every legacy
encoding, comparison with JRuby regex/string primitives, or CRuby+C throughput.
No strict throughput gate has been added to shared CI runners.
