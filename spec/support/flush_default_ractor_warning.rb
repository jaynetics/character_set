previous_verbose = $VERBOSE
$VERBOSE = nil
defined?(Ractor) && Ractor.new { nil }
$VERBOSE = previous_verbose
