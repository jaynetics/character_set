package org.jaynetics.characterset;

import org.jruby.Ruby;
import org.jruby.RubyClass;
import org.jruby.runtime.load.BasicLibraryService;

public final class CharacterSetService implements BasicLibraryService {
    @Override
    public boolean basicLoad(Ruby runtime) {
        RubyClass klass = runtime.getClass("CharacterSet");
        klass.setAllocator(RubyCharacterSet::new);
        klass.defineAnnotatedMethods(RubyCharacterSet.class);
        return true;
    }
}
