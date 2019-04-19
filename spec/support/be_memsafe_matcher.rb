RSpec::Matchers.define(:be_memsafe) do |runs: 20_000|
  match do |actual|
    raise 'this matcher is only for callables' unless actual.respond_to?(:call)

    # TODO: consider choosing some appropriate limit for MJIT
    # and stop skipping this once it does not randomly fail
    skip 'cant check memsafety with MJIT' if (RubyVM::MJIT.enabled? rescue nil)

    skip 'cant check memsafety on this platform' if RUBY_PLATFORM[/java/i]

    skip 'SKIP_MEMSAFETY_SPECS is set' if ENV['SKIP_MEMSAFETY_SPECS'].to_i == 1

    pscmd = ['ps', '-orss=', '-p', $$.to_s]
    pspat = /^\s*(\d+)$/
    get_rss = ->{ IO.popen(pscmd).read[pspat, 1].to_i * 1024 }
    get_rss.call rescue skip 'cant check memsafety in environments without `ps`'

    # warm up
    (runs / 10).times { actual.call }
    GC.start

    before = get_rss.call
    runs.times { actual.call  }
    GC.start
    after = get_rss.call

    # fail if memory usage grew more than 10 bytes per run
    if (bytes_grown = after - before) > runs * 10
      @msg = "rss grew by #{bytes_grown} bytes: #{before} => #{after}"
      return false
    end

    true
  end

  failure_message { @msg }

  supports_block_expectations
end
