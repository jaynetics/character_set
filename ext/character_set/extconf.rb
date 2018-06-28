require 'mkmf'

$CFLAGS << ' -Wextra -Wno-unused-parameter -Wall -pedantic '

create_makefile('character_set/character_set')
