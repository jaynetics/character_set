require 'get_process_mem'

RSpec::Matchers.define(:be_memsafe) do
  match do |block|
    raise 'this matcher is only for callables' unless block.respond_to?(:call)

    skip 'no need to check memsafety on this platform' if RUBY_PLATFORM[/java/i]
    skip 'SKIP_MEMSAFETY_SPECS is set' if ENV['SKIP_MEMSAFETY_SPECS'].to_i == 1
    skip 'memsafety check requires GC.compact' unless defined?(GC.compact)

    puts '  Checking memsafety! This can take LONG. Run `spec:quick` to skip.'

    # warmup
    10.times { 10.times(&block) && GC.compact }

    before = GetProcessMem.new.bytes.round
    100.times { 10.times(&block) && GC.compact }
    after = GetProcessMem.new.bytes.round

    @msg = "rss grew by #{after - before} bytes: #{before} => #{after}"
    puts '  ' + @msg
    return after.to_f / before.to_f < 1.05
  end

  failure_message { @msg }

  supports_block_expectations
end
