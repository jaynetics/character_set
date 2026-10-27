# Java backend implementation plan

Prepared: 2026-10-26

## Implementation status: 2026-10-26

The initial backend is implemented in the working tree. The Java class registers
the C backend's method surface, uses `BitSet` directly, and includes string
processing, Unicode sections, and the existing casefold mappings. Build/loading,
gem packaging, isolated installation checks, backend identity assertions, and
stable/head CI configuration are in place.

Validated locally:

- JRuby 10.1.1.0 on Java 25: 858 examples, zero failures, 13 existing pending cases.
- JRuby 10.1.1.0 on Java 21: 858 examples, zero failures, 13 existing pending cases.
- CRuby 4.0.7: 884 examples, zero failures, 11 existing pending cases.
- Installation and execution of the Java gem outside the checkout on Java 25.
- Six development benchmark cases across three independent JVMs per backend;
  see [measurements and limitations](JAVA_BENCHMARK.md).

Implementation choices refined from this proposal:

- `RubyCharacterSet` owns its `BitSet` directly; an additional `CodepointSet`
  wrapper was unnecessary for the current implementation.
- Casefold mappings are packaged as a binary resource generated from the existing
  C header during compilation, with no Unicode data refresh.
- The Java gem requires Ruby compatibility version 4.0 or later, matching the
  initially supported JRuby 10.1 line; Java bytecode targets version 21.
- The independent-process benchmark runner is `tasks/java_benchmark.rb`.

Remaining release validation includes the broader performance matrix, longer
warmup runs, startup/retained-memory profiling, and the newly configured CI jobs
on Linux and `jruby-head`. The plan below retains the original effort estimate
and describes the full intended validation scope.

## Objective and estimate

Implement a Java backend for `CharacterSet` on JRuby, preserving the public Ruby API and providing good performance for set operations and string processing. Ship the compiled backend in the existing Java-platform gem.

Estimated effort: **6–10 engineering days** for one developer familiar with Ruby extensions and Java. A prototype demonstrating extension loading, membership, and one string loop should take **1–2 days**, included in that total. The estimate covers implementation, compatibility work, packaging, benchmarks, and CI; it is not a measured delivery commitment.

| Workstream | Effort | Result |
| --- | --- | --- |
| Baseline, extension loading, build, packaging | 1–2 days | Java class registered as `CharacterSet`; reproducible JAR and gem build |
| Set storage and operations | 1–2 days | Bitset-backed implementation of the backend's set API |
| String operations and encoding behavior | 2–3 days | Java loops for scanning, counting, filtering, and string construction |
| Compatibility, performance tuning, release checks | 2–3 days | Passing specs, benchmark report, installed-gem validation, CI |
| **Total** | **6–10 days** | **Releasable JRuby backend** |

This scope assumes the repository's configured JRuby 10.1.1.0 as the initial stable target, plus `jruby-head` as a compatibility check. Adding support for older JRuby major versions requires separate API and JDK compatibility work. The initial build and CI environment should use a full JDK 25, matching the existing JRuby CI Java version. Determine and record the minimum runtime and bytecode target during the baseline phase; a JRE-only installation cannot build the extension.

## Scope

Included:

- Replace the Ruby fallback as the default backend on supported JRuby installations.
- Implement the methods currently supplied by the C extension in Java.
- Reuse Ruby parsing, expression conversion, writing, predefined sets, method adapters, and higher-level methods.
- Preserve `CharacterSet::Pure` as an independently usable Ruby implementation.
- Preserve CRuby's C backend and the fallback path for other supported Ruby engines.
- Maintain optional-dependency behavior, including regex/property conversion.
- Extend the existing spec and benchmark infrastructure where necessary.

Outside this implementation:

- A standalone Java library with a separate Java-facing API.
- JNI, changes to the C storage representation, or a rewrite of the Ruby parser and writer.
- A Unicode data update, a new regex engine, or expanded regex syntax.
- SIMD, compressed bitmaps, parallel string processing, and custom storage before profiling establishes a need.
- New thread-safety guarantees for mutable sets or strings.

## Repository findings

| Location | Current behavior | Consequence |
| --- | --- | --- |
| `ext/character_set/character_set.c` | 1,366 lines implementing storage and the native method surface | Main implementation reference and porting checklist |
| `lib/character_set.rb` | Loads the C extension, then falls back to Ruby on `LoadError` | Add explicit JRuby backend selection |
| `lib/character_set/shared_methods.rb` | Shared initialization, optional dependency loading, keyword wrappers, writing, and convenience methods | Keep these methods unless a measured hotspot requires an override |
| `lib/character_set/set_method_adapters.rb` | Normalizes character/integer arguments and some enumerable operands | Preserve method lookup order and validate bulk inputs in Java too |
| `lib/character_set/ruby_fallback/` | Hash-backed implementation with sorted-key caching | Useful same-runtime baseline and partial differential oracle |
| `lib/character_set/pure.rb` | Explicitly composes the Ruby implementation | Must remain independent of Java storage and methods |
| `Rakefile` | Already builds a Java-platform gem, without native extensions | Add compilation and inclusion of the JAR |
| `.github/workflows/tests.yml` | Includes `jruby-head` on Java 25 | Add a stable JRuby job and assert the Java backend is active |
| `spec/support/tested_encodings.rb` | Lists ten string encodings; individual specs also exercise EUC-JP | Encoding support is part of existing behavior |
| `tasks/benchmarks/` | Existing IPS comparisons mostly target CRuby-era string operations | Extend for backend comparisons and JVM warmup |
| `BENCHMARK.md` | Records results from a 2022 CRuby development build | Historical context only; establish new baselines |

The C representation is already a growing bitmap. Several C operations inspect the entire Unicode domain one codepoint at a time. A Java implementation can use bulk bit operations and iterate only populated bits, creating an opportunity to improve those operations without a complex data structure. This is an expectation to measure, not a promised speedup.

## Proposed architecture

### Backend loading and object model

Use a Java class extending JRuby's `RubyObject`, allocated as the existing Ruby `CharacterSet` class, with a JRuby extension service registering methods. Keep the Ruby class identity, aliases, subclass allocation, `Enumerable`, `SharedMethods`, and `SetMethodAdapters` intact.

Proposed implementation files:

| File | Responsibility |
| --- | --- |
| `ext/character_set/java/src/main/java/org/jaynetics/characterset/CharacterSetService.java` | Register the Ruby class allocator and Java-backed methods |
| `ext/character_set/java/src/main/java/org/jaynetics/characterset/RubyCharacterSet.java` | Ruby-facing methods, argument handling, object allocation, block callbacks |
| `ext/character_set/java/src/main/java/org/jaynetics/characterset/CodepointSet.java` | Bitset storage and operations without Ruby callbacks |
| `ext/character_set/java/src/main/java/org/jaynetics/characterset/StringOperations.java` | Encoding-aware input traversal, filtering, and Ruby string output |
| `ext/character_set/java/src/main/java/org/jaynetics/characterset/CaseFoldData.java` | Generated mappings matching the existing checked-in table |
| `lib/character_set/java.rb` | Require the packaged JAR and invoke the extension service |
| `lib/character_set/character_set.jar` | Generated artifact included in the Java-platform gem |
| `tasks/java.rake` | Compile, package, and clean Java build outputs |
| `tasks/benchmarks/java_backend.rb` | Backend comparison workloads and reporting |

These names are the implementation proposal, not files that currently exist. Avoid introducing public Java APIs or Ruby configuration options just to support internal organization.

Loading rules:

1. On JRuby, load the Java backend before composing the shared Ruby behavior.
2. On CRuby, retain the C extension loading path.
3. Preserve Ruby fallback behavior when no backend artifact is available, such as an unbuilt development checkout. Report a broken or incompatible installed JAR clearly rather than silently hiding linkage or registration failures.
4. Keep `CharacterSet::Pure` explicitly Ruby-backed regardless of the selected backend.
5. Add a test-only backend assertion using the Java class/service identity, so CI cannot pass accidentally against the fallback. Avoid relying solely on `source_location` or incidental instance variables.

### Storage and algorithms

Start with a dynamically growing `java.util.BitSet` behind `CodepointSet`.

- Store Unicode codepoints in `0..0x10FFFF` as integer bit indices; include surrogate codepoints when explicitly requested by the existing API.
- Bound every public bulk operation before changing storage. Java arrays and bitsets must never grow in response to an invalid arbitrarily large Ruby integer.
- Use bulk `or`, `and`, `andNot`, `xor`, `flip`, and range setters rather than per-codepoint loops.
- Iterate using `nextSetBit`; build ranges using transitions between set and clear bits.
- Use `cardinality`, `isEmpty`, and set-bit searches for counts and extrema. Add a cached cardinality only if profiling justifies the invalidation complexity.
- Bound complements to the requested inclusive upper limit and clear the surrogate interval by default.
- Preserve absolute codepoint indices in `section`; `BitSet.get(from, to)` rebases indices and cannot directly represent that result.
- Deep-copy mutable storage for `dup`, `clone`, and new set results.
- Keep result allocation tied to the receiver's Ruby class where existing behavior requires it.

A full Unicode bitmap contains 1,114,112 bits, or **136 KiB of bit payload**, excluding object overhead and any spare capacity. Grow small sets on demand rather than allocating the full domain for every instance. Record actual retained capacity, especially after a high codepoint is inserted and removed.

Use a custom `long[]` only if profiling identifies a concrete `BitSet` limitation. Replacing `BitSet` is an additional tuning task, not assumed in the base estimate.

### String processing

Implement `of_string`, `count_in`, `cover?`, `used_by?`, `scan`, `delete_in`, `keep_in`, and the bang variants as Java loops over JRuby string storage.

- Use JRuby's byte buffers, encoding metadata, validation, and transcoding helpers. Keep JRuby-specific APIs isolated in `StringOperations` to limit version coupling.
- Provide a direct ASCII path and a validated UTF-8 decoding path.
- Use primitive integer codepoints for membership checks. Allocate Ruby objects only for returned values and explicit Ruby block callbacks.
- For `cover?` and `used_by?`, exit as soon as the result is known, subject to the characterized invalid-input behavior.
- Decode to Unicode values for other encodings using JRuby's transcoding support. Some encoding libraries return encoding-specific packed values; those are not Unicode codepoints. The existing EUC-JP `of_string` spec explicitly tests this distinction.
- Preserve the API's treatment of binary strings separately from text transcoding. Characterize non-ASCII bytes before selecting a single-byte fast path.
- Preserve the original encoding for filtering results, transcoding back where required. Construct `scan` results with the encoding expected by the existing API.
- Copy surviving byte spans where safe instead of decoding and re-encoding each retained character.
- Respect byte-buffer offsets and lengths, including substrings that share storage.
- Respect JRuby's frozen checks, copy-on-write behavior, and code-range invalidation when mutating strings.
- Preserve bang-method object identity and `nil` when unchanged. Never mutate another string sharing the input's buffer.
- Avoid whole-string conversion through Java `String` on hot paths; it adds conversion work and changes the treatment of malformed input and surrogate codepoints.

Non-UTF-8 support can initially use a correct transcoding path. Further specialization belongs in tuning only if those encodings are relevant to the measured workloads.

### Casefolding and Unicode data

Generate Java mappings from the same checked-in mappings currently used by C. The current table contains 1,426 pairs; keep its behavior and data version for this port.

- Preserve single-codepoint mapping behavior and the exclusion of multi-codepoint replacements.
- Apply mappings with the same source-membership rules as the existing C implementation; do not accidentally introduce additional transitive folding in the port.
- Do not substitute `Character.toUpperCase`, `toLowerCase`, or the host JDK's Unicode property tables: their behavior and Unicode versions can differ.
- Extend the generation workflow so a future intentional data refresh produces both outputs from one input, with a recorded Unicode version and deterministic output.
- Routine compilation must use checked-in data and require no Unicode download. The initial port must not refresh the existing mappings incidentally.
- Continue loading predefined `.cps` resources and optional property ranges through the existing Ruby code.

## Compatibility checklist

Audit the registrations in `Init_character_set` and account for every method and alias. Use the following groups to drive implementation and review:

| Group | Methods and behavior |
| --- | --- |
| Allocation and copying | Constructor path, subclass allocation, `initialize_dup`, `initialize_clone`, frozen state |
| Membership and mutation | `include?`, `member?`, `===`, `add`, `<<`, `add?`, `delete`, `delete?`, `clear`, `merge`, `subtract` |
| Enumeration and conversion | `each`, sized enumerators, ascending order, `to_a`, optional stringification, `ranges`, `sample` |
| Basic queries | `length`, `size`, `empty?`, `min`, `max`, `minmax`, `hash` |
| Algebra | Union, intersection, difference, symmetric difference, all operator aliases |
| Relations | Equality, `eql?`, subset/superset, proper variants, intersection/disjointness, `<=>` |
| Unicode sections | `ext_section`, `ext_count_in_section`, `ext_section?`, `ext_section_ratio`, planes and plane queries |
| Construction helpers | `from_ranges`, `of_string`, inclusive/exclusive/empty ranges |
| Unicode transformations | `ext_inversion`, surrogate handling, `case_insensitive` |
| String operations | Counting, coverage, detection, scanning, filtering, mutation |
| Diagnostic method | Inventory callers of `allocated_length`; document its capacity meaning if it remains backend-specific |

Additional compatibility decisions:

- Keep the shared initialization/parser contract; existing specs stub `Parser.codepoints_from_enumerable` and expect construction to call it.
- Validate every bulk member, not just the first member inspected by the Ruby parser.
- Preserve blockless enumerators, block return handling, and exception propagation.
- Characterize mutation during block iteration before selecting live versus snapshot iteration behavior.
- Enforce frozen checks consistently, including operations that would otherwise be no-ops.
- Compare sets by content regardless of storage capacity or insertion history. Ensure equal values under `eql?` produce equal hashes; exact numeric hashes across Ruby processes or engines are not a requirement.
- Preserve existing equality behavior involving descendants and `CharacterSet::Pure`; do not assume `==` and `eql?` have identical cross-class rules. Cover both operand directions where supported.
- Normalize generic enumerables through the existing adapter contract and give Java-backed operands a direct bulk-operation path.
- Preserve exceptions, return values, empty-set results, and section-ratio edge cases established by specs.
- Preserve optional dependency failures and Ruby-only behavior of `CharacterSet::Pure`.

The C and Ruby implementations are useful references but are not interchangeable correctness oracles. For example, the C single-byte string path treats bytes directly, while the fallback transcodes to UTF-8. Classify disagreements with non-ASCII legacy encodings explicitly, using the documented Unicode semantics and regression tests. Correct accidental backend inconsistencies deliberately rather than reproducing them through an optimization.

## Implementation phases and completion criteria

### Phase 1: Establish baseline and build a vertical slice

Tasks:

1. Record the revision, working tree state, Ruby/JRuby versions, JDK, OS, CPU, and JVM options.
2. Use a full JDK and confirm `javac`, `jar`, and the runtime refer to the intended installation. The repository currently selects a JRE distribution locally.
3. Run the existing specs on stable JRuby using the fallback and on a supported CRuby using the C extension. Record pre-existing failures separately.
4. Save fallback benchmark results before changing backend selection.
5. Create the method/alias inventory and fixtures for the compatibility decisions above.
6. Add Rake-based compilation using the target JRuby distribution's JAR as a compile-time dependency. Use `javac` and `jar`; avoid introducing a separate build ecosystem for this small extension.
7. Register the allocator and implement a minimal set with membership plus `count_in` for ASCII/UTF-8. Wire loading, adapters, and shared initialization.
8. Build a Java-platform gem containing the JAR and install it in a temporary gem environment outside the checkout's load path.

Completion criteria:

- The installed gem demonstrably executes Java methods on stable JRuby.
- CRuby still loads the C backend and `CharacterSet::Pure` still loads Ruby methods.
- One representative warmed string loop can be compared with the saved fallback baseline.
- The runtime/bytecode support floor and any API compatibility issues are recorded.

This is the 1–2 day prototype checkpoint. Significant JRuby API or packaging problems found here should update the remaining estimate before expanding the port.

### Phase 2: Complete storage, set operations, and Unicode helpers

Tasks:

1. Complete mutation, bulk range construction, algebra, relations, and extrema using bitset operations.
2. Implement ascending enumeration, ranges, Ruby array/string conversion, and sampling while preserving existing distribution and return semantics.
3. Implement sections, section counts and ratios, planes, and inversion.
4. Generate and integrate the Java casefold table.
5. Complete copying, equality, hashing, frozen checks, and mixed operand handling.
6. Exercise shared parser, writer, regex conversion, predefined sets, token generation, and convenience methods against Java-backed objects.

Completion criteria:

- Existing set and Unicode-helper specs pass on the Java backend.
- Boundary tests cover `0`, `127/128`, `63/64`, `0xD7FF/0xD800`, `0xDFFF/0xE000`, `0xFFFF/0x10000`, and `0x10FFFF`.
- Randomized sequences of mutations and algebra agree with a small independent integer-set model.
- Copies and algebra results have no shared mutable backing storage.
- Dense algebra uses bulk operations rather than a loop through all 1,114,112 codepoints.

### Phase 3: Complete string operations

Tasks:

1. Finish UTF-8 validation and implement the full scanning/counting/detection method family.
2. Implement filtering and bang variants using safe JRuby string mutation and span copying.
3. Add the general transcoding path and preserve filtering result encodings.
4. Verify binary input, invalid byte sequences, substring offsets, shared buffers, and frozen strings.
5. Check early exits for matches at the start/end and absent matches, including malformed input after a potential early exit.
6. Keep object creation outside the inner loops except for `scan` output elements and required callbacks.

Completion criteria:

- Existing string specs pass across all listed encodings and EUC-JP.
- Non-ASCII fixtures cover legacy encodings; ASCII-only samples are insufficient to validate transcoding.
- Unchanged bang calls return `nil`; changed calls return and mutate the original object.
- Mutating an input never changes another string sharing its buffer.
- Supplementary characters are counted and returned as codepoints, not UTF-16 halves.

### Phase 4: Validate, tune, and prepare release artifacts

Tasks:

1. Run the complete existing suite on stable JRuby and CRuby, and exercise `jruby-head`.
2. Add only missing contract and regression specs, with randomized differential coverage for operations where the references agree.
3. Check whether `Leto.shared_mutable_state?` traverses the Java-backed state; supplement it with explicit mutation-isolation assertions where it cannot.
4. Run the benchmark protocol below and profile the largest relevant bottlenecks.
5. Tune only measured issues, then rerun affected specs and benchmark cases.
6. Add CI compilation, backend identity assertions, and installed-gem smoke tests.
7. Document runtime support, build commands, backend selection, performance results, and known limitations. Add the release changelog entry.

Completion criteria:

- The compatibility and performance acceptance criteria below are met or explicit exceptions are documented.
- A clean checkout can build a gem with a complete JAR and data resources.
- The installed Java gem runs without a compiler or build-time downloads.
- CRuby and explicit pure-Ruby usage remain functional.

## Performance validation

### Comparisons and workload matrix

Compare the new Java backend against the original fallback under the **same JRuby/JVM configuration**. Also compare `CharacterSet::Pure` and relevant JRuby string/regex operations. Treat CRuby+C as a separately labeled reference, not a controlled measure of backend improvement.

| Dimension | Cases |
| --- | --- |
| Set shape | Empty; small ASCII; sparse BMP; sparse astral; dense ranges; full Unicode; complement |
| Operations | Membership, add/delete, construction, range merge, algebra, relations, size, extrema, iteration, ranges |
| String length | Empty, approximately 16 bytes, 1 KiB, 64 KiB, and 1 MiB |
| Content | ASCII, accented BMP, emoji/astral, mixed text, representative legacy encodings |
| Match location | First character, middle, last character, absent |
| Match density | None, sparse, approximately half, all |
| Result behavior | Unchanged filtering, heavy filtering, `scan` output, bang/non-bang variants |
| Memory | Tiny sets, high-codepoint sets, high codepoint removed, copies, repeated filtering |

Use the combinations relevant to each operation instead of running the entire Cartesian product. Select the representative release cases during Phase 1, before inspecting Java results.

### Measurement protocol

1. Record exact runtime versions, hardware, JVM/GC options, and input/set sizes with every report.
2. Construct fixtures outside timed loops except when construction is the operation being measured.
3. Correct mutation fixtures: the existing `z_merge.rb` reuses a recipient that becomes fully merged after the first call. Measure real merging and no-op merging separately; do the same for bang filtering and add/delete.
4. Warm the JVM for at least 10 seconds initially and increase that duration if throughput has not stabilized. Use at least three independent processes and report medians plus variability.
5. Retain early-exit cases and tiny inputs; long-string throughput alone can hide Ruby/Java call overhead.
6. Measure public Ruby calls as the release metric. A Java-only microbenchmark may diagnose a bottleneck but cannot establish user-visible performance.
7. Consume and check results outside timing where practical. Validate results so a faster but incorrect path cannot win the comparison.
8. Record throughput/latency and allocation or GC observations. Use a JVM profiler or JFR when necessary; RSS-only comparisons and the CRuby memsafety matcher do not validate Java allocation behavior.
9. Measure first load and first use separately from warmed throughput, including casefold-data initialization.

### Proposed performance acceptance criteria

These are release targets to validate, not predictions already established by measurements:

- At least **2× median throughput over the original JRuby fallback** on the preselected representative long UTF-8 string workloads and large-set algebra workloads. Record individual cases as well as any aggregate.
- Investigate regressions greater than **20%** on representative tiny membership, mutation, and early-exit workloads; distinguish reproducible regressions from noise.
- Membership and counting loops allocate no Ruby object per inspected codepoint. String filtering allocates output and necessary conversion buffers; `scan` allocation follows returned elements.
- Tiny ASCII sets do not eagerly allocate a full Unicode bitmap. Full-domain payload remains close to the expected bitmap size, with actual object and spare-capacity overhead reported.
- Both changed and unchanged filtering paths have measured results. No benchmark silently substitutes no-op work for mutation.

If a target is missed, profile the failing workload and document whether the issue is call overhead, conversion, algorithm choice, allocation, or measurement noise. Resolve it or explicitly revise the release expectation with evidence. Do not claim universal superiority over JRuby regex/string primitives or CRuby+C.

## Testing and CI

Use the existing `bundle exec rake spec:quick` entry point. The current memsafety matcher intentionally skips JRuby; keep that behavior and use explicit aliasing checks and JVM allocation measurements for the Java backend.

Add focused coverage for:

- Invalid integers, enormous integers, mixed-validity arrays, and bounded range operations.
- Empty, descending, exclusive, and open-ended ranges.
- Mutators on frozen sets and strings, including no-op mutations.
- All operator aliases, sized enumerators, subclass results, copy independence, and hashing after different construction histories.
- Non-ASCII bytes in single-byte encodings; EUC-JP; malformed UTF-8; binary strings; supplementary characters; surrogate policy.
- Buffer sharing and nonzero offsets, including mutation after `dup` or substring construction.
- `CharacterSet::Pure` interoperability in the directions the public API supports.
- Identical mappings between generated C and Java casefold data.
- Missing artifact versus incompatible artifact behavior, with backend selection checks in separate Ruby processes.

CI layout:

| Job | Checks |
| --- | --- |
| Existing CRuby matrix | Existing compilation and specs; verify Java integration does not alter C loading |
| Stable JRuby 10.1.1.0 + JDK 25 | Compile Java, assert backend identity, run specs, package and smoke-test installed gem |
| `jruby-head` + JDK 25 | Compile and run specs to detect JRuby API drift |
| Declared minimum Java runtime | Load and smoke-test the built artifact once the runtime floor is established |

Extend the existing workflow rather than introducing an unrelated pipeline. Avoid strict throughput gates on shared CI runners; retain a reproducible performance task and publish recorded results for review.

Proposed new task names:

```text
bundle exec rake java:compile
bundle exec rake java:verify_backend
bundle exec rake spec:quick
bundle exec rake java:gem
bundle exec rake java:smoke
bundle exec rake benchmark:java
```

`spec:quick` on JRuby should compile before testing, and `java:gem` should depend on compilation. `java:smoke` should install the built gem into an isolated temporary environment, remove checkout-specific load paths, and verify backend identity and representative set/string operations. These tasks are proposed additions; `java:gem` and `spec:quick` already exist.

## Packaging and maintainability

- Compile against JRuby supplied by the chosen build runtime; do not bundle JRuby, JCodings, or Joni inside this gem's JAR.
- Ship one JAR and the existing Ruby/data files in the Java-platform gem. End users require a supported JRuby runtime, not a C compiler or JDK.
- Handle the gemspec's use of `git ls-files`: explicitly add the generated JAR to the Java gem file list so an untracked build artifact is included. Exclude it from the generic CRuby gem unless there is a documented reason to ship it there.
- Keep build products in predictable generated directories with matching clean tasks. Rebuild the JAR when Java sources or generated mappings change.
- Keep `range_compressor` in the Java gem initially: `CharacterSet::Pure#ranges` still relies on it even if Java-backed `ranges` does not.
- Preserve compatibility of shared Ruby source with the repository's older CRuby targets. Keep JRuby-specific code behind the JRuby loader.
- Record compile target, minimum JRuby/JDK, generation inputs, and exact reproducible build/test commands in project documentation.
- Use an explicit Ruby implementation for fallback selection, not partial composition of failed Java initialization and fallback state.

## Risks and decision points

| Risk | Handling | Estimate impact if material |
| --- | --- | --- |
| JRuby API drift | Isolate runtime-specific calls; test stable and head; compile against the stable target | Broader version support can add 1–3 days |
| Non-UTF-8 mapping differences | Transcode to Unicode; add non-ASCII fixtures; characterize binary semantics | Unusual encoding fixes can add 1–2 days |
| C/fallback disagreements | Use specs and documented semantics, record discrepancies, add regression cases | Reassess if a public behavior decision blocks implementation |
| Frozen/shared buffer errors | Reuse JRuby mutation helpers; test identity, offsets, and isolation | Expected within string work; extensive API issues require re-estimation |
| Tiny-call overhead | Benchmark public Ruby methods early; retain adapters unless profiling supports a change | May limit speedups for individual calls |
| Java storage invisible to Ruby inspection tools | Explicitly mutate copies/results to prove isolation | Expected within validation work |
| Generated JAR omitted from package | Inspect artifact contents and test an installed gem outside the checkout | Expected within packaging work |
| Casefold data or initialization drift | Share existing mappings; deterministic generation; compare emitted data | Expected within Unicode-helper work |
| Performance target missed | Profile representative cases before choosing custom storage or extra specialization | Major storage redesign can add 2–4 days |

The 6–10 day range includes ordinary integration and tuning. The extra estimates above are contingencies and are not already scheduled work. A standalone Java API, older JRuby support, or a requirement to beat CRuby+C across all workloads would change scope and require a new estimate.

## Suggested implementation commits

1. Add Java extension build/load infrastructure, a minimal vertical slice, backend identity assertions, and installed-gem smoke coverage.
2. Complete bitset operations, Ruby object lifecycle behavior, and set compatibility coverage.
3. Add Unicode sections, inversion, and generated casefold data.
4. Complete fast string operations and encoding/mutation regression coverage.
5. Add reproducible backend benchmarks, correct mutation fixtures, and apply measured tuning.
6. Finalize stable/head CI, packaging checks, documentation, and release notes.

Each commit should keep CRuby behavior and explicit pure-Ruby usage working. During development, avoid presenting a partial backend as release-ready or allowing CI to test a fallback accidentally.

## Definition of done

- [ ] Every C backend registration and alias is accounted for by Java or an intentional shared implementation.
- [ ] Existing specs pass on stable JRuby with the Java backend asserted active.
- [ ] CRuby and `CharacterSet::Pure` remain functional under the existing test entry points.
- [ ] Targeted encoding, bounds, copying, freezing, and mutation checks pass.
- [ ] Stable/head JRuby checks and the declared Java runtime floor are covered.
- [ ] New benchmark results include versions, warmup, variability, real mutation, and allocation observations.
- [ ] Performance targets are met or explicit limitations are documented with measurements.
- [ ] A clean build produces a complete Java gem that runs after installation outside the checkout.
- [ ] Runtime requirements, build commands, backend selection, and data-generation workflow are documented.

## Technical references

- [Java `BitSet` API](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/util/BitSet.html): available bit operations, range operations, and iteration primitives.
- [JRuby `RubyString` implementation](https://github.com/jruby/jruby/blob/master/core/src/main/java/org/jruby/RubyString.java): byte storage, encoding metadata, mutation, and shared-buffer handling. Inspect the supported release's source during implementation; `master` is a moving reference.
- [JRuby Java integration documentation](https://github.com/jruby/jruby/wiki/CallingJavaFromJRuby): requiring JARs and Java class loading.

The implementation status above records completed local checks. Other tasks and
acceptance criteria in this document remain a plan unless explicitly recorded
there or in the linked benchmark report.
