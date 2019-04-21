require 'get_process_mem'

RSpec::Matchers.define(:be_memsafe) do
  match do |actual|
    raise 'this matcher is only for callables' unless actual.respond_to?(:call)

    skip 'no need to check memsafety on this platform' if RUBY_PLATFORM[/java/i]
    skip 'SKIP_MEMSAFETY_SPECS is set' if ENV['SKIP_MEMSAFETY_SPECS'].to_i == 1

    # If 1000 iterations can complete without growth, there is no leak.
    # Retry that 20 times because rss sometimes grows due to mere fragmentation.
    20.times do
      @before = GetProcessMem.new.bytes.round
      1000.times { actual.call }
      GC.start
      @after = GetProcessMem.new.bytes.round
      return true if @after - @before == 0
    end

    @msg = "rss grew by #{@after - @before} bytes: #{@before} => #{@after}"
    return false
  end

  failure_message { @msg }

  supports_block_expectations
end
