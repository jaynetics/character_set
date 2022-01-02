previous_verbose = $VERBOSE
$VERBOSE = nil
defined?(Ractor) && Ractor.new {}
$VERBOSE = previous_verbose
