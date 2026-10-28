package org.jaynetics.characterset;

import java.util.BitSet;
import org.jcodings.specific.UTF8Encoding;
import org.jruby.Ruby;
import org.jruby.RubyArray;
import org.jruby.RubyClass;
import org.jruby.RubyEnumerator;
import org.jruby.RubyFixnum;
import org.jruby.RubyObject;
import org.jruby.RubyRange;
import org.jruby.RubyString;
import org.jruby.anno.JRubyMethod;
import org.jruby.runtime.Block;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.Visibility;
import org.jruby.runtime.builtin.IRubyObject;

public final class RubyCharacterSet extends RubyObject {
    static final int LIMIT = 0x110000;
    private BitSet bits = new BitSet(128);

    public RubyCharacterSet(Ruby runtime, RubyClass klass) {
        super(runtime, klass);
    }

    static int codepoint(ThreadContext context, IRubyObject value) {
        if (value instanceof RubyFixnum) {
            long cp = ((RubyFixnum) value).getLongValue();
            if (cp >= 0 && cp < LIMIT) return (int) cp;
        }
        throw context.runtime.newArgumentError("CharacterSet members must be between 0 and 0x10FFFF");
    }

    private RubyCharacterSet result(ThreadContext context, BitSet data) {
        RubyCharacterSet set = (RubyCharacterSet) getMetaClass().getRealClass().allocate();
        set.bits = data;
        return set;
    }

    private static RubyCharacterSet construct(ThreadContext context, IRubyObject klass) {
        return (RubyCharacterSet) ((RubyClass) klass).newInstance(context, Block.NULL_BLOCK);
    }

    private static boolean characterSet(ThreadContext context, IRubyObject value) {
        RubyClass klass = context.runtime.getClass("CharacterSet");
        if (klass.isInstance(value)) return true;
        IRubyObject pure = klass.getConstantAt("Pure");
        return pure instanceof RubyClass && ((RubyClass) pure).isInstance(value);
    }

    private static BitSet operand(ThreadContext context, IRubyObject other) {
        if (other instanceof RubyCharacterSet) return ((RubyCharacterSet) other).bits;
        if (!characterSet(context, other)) throw context.runtime.newArgumentError("pass a CharacterSet");
        BitSet data = new BitSet();
        RubyArray<?> values = (RubyArray<?>) other.callMethod(context, "to_a");
        for (int i = 0; i < values.getLength(); i++) data.set(codepoint(context, values.entry(i)));
        return data;
    }

    private IRubyObject enumerator(ThreadContext context, String method) {
        return RubyEnumerator.enumeratorizeWithSize(context, this, method,
                (ctx, self, args) -> ctx.runtime.newFixnum(((RubyCharacterSet) self).bits.cardinality()));
    }

    @JRubyMethod(name = {"size", "length"})
    public IRubyObject size(ThreadContext context) {
        return context.runtime.newFixnum(bits.cardinality());
    }

    @JRubyMethod(name = "empty?")
    public IRubyObject empty(ThreadContext context) {
        return context.runtime.newBoolean(bits.isEmpty());
    }

    @JRubyMethod(name = {"include?", "member?", "==="})
    public IRubyObject includes(ThreadContext context, IRubyObject value) {
        return context.runtime.newBoolean(bits.get(codepoint(context, value)));
    }

    @JRubyMethod(name = {"add", "<<"})
    public IRubyObject add(ThreadContext context, IRubyObject value) {
        checkFrozen();
        bits.set(codepoint(context, value));
        return this;
    }

    @JRubyMethod(name = "add?")
    public IRubyObject addIfAbsent(ThreadContext context, IRubyObject value) {
        checkFrozen();
        int cp = codepoint(context, value);
        if (bits.get(cp)) return context.nil;
        bits.set(cp);
        return this;
    }

    @JRubyMethod(name = "delete")
    public IRubyObject delete(ThreadContext context, IRubyObject value) {
        checkFrozen();
        bits.clear(codepoint(context, value));
        return this;
    }

    @JRubyMethod(name = "delete?")
    public IRubyObject deleteIfPresent(ThreadContext context, IRubyObject value) {
        checkFrozen();
        int cp = codepoint(context, value);
        if (!bits.get(cp)) return context.nil;
        bits.clear(cp);
        return this;
    }

    @JRubyMethod(name = "clear")
    public IRubyObject clear(ThreadContext context) {
        checkFrozen();
        bits.clear();
        return this;
    }

    private void mergeRange(ThreadContext context, RubyRange range) {
        int from = codepoint(context, range.begin(context));
        IRubyObject end = range.end(context);
        if (!(end instanceof RubyFixnum)) throw context.runtime.newArgumentError("pass a bounded codepoint Range");
        long upto = ((RubyFixnum) end).getLongValue();
        if (range.isExcludeEnd()) upto--;
        if (upto < -1 || upto >= LIMIT) throw context.runtime.newArgumentError("Range exceeds Unicode codepoints");
        checkFrozen();
        if (upto >= from) bits.set(from, (int) upto + 1);
    }

    private static boolean stringRange(ThreadContext context, IRubyObject value) {
        if (!(value instanceof RubyRange)) return false;
        RubyRange range = (RubyRange) value;
        return range.begin(context) instanceof RubyString && range.end(context) instanceof RubyString;
    }

    @JRubyMethod(name = "merge")
    public IRubyObject merge(ThreadContext context, IRubyObject other) {
        checkFrozen();
        if (other instanceof RubyCharacterSet) {
            bits.or(((RubyCharacterSet) other).bits);
        } else if (other instanceof RubyRange && !stringRange(context, other)) {
            mergeRange(context, (RubyRange) other);
        } else {
            if (!other.respondsTo("each")) throw context.runtime.newArgumentError("pass an Enumerable");
            RubyArray<?> values = (RubyArray<?>) other.callMethod(context, "to_a");
            checkFrozen();
            for (int i = 0; i < values.getLength(); i++) {
                IRubyObject value = values.entry(i);
                if (value instanceof RubyString) value = value.callMethod(context, "ord");
                int cp = codepoint(context, value);
                checkFrozen();
                bits.set(cp);
            }
        }
        return this;
    }

    @JRubyMethod(name = "subtract")
    public IRubyObject subtract(ThreadContext context, IRubyObject other) {
        checkFrozen();
        BitSet data = operand(context, other);
        checkFrozen();
        bits.andNot(data);
        return this;
    }

    @JRubyMethod(name = "initialize_copy", visibility = Visibility.PRIVATE)
    public IRubyObject copy(ThreadContext context, IRubyObject source) {
        checkFrozen();
        BitSet data = operand(context, source);
        checkFrozen();
        bits = (BitSet) data.clone();
        return this;
    }

    @JRubyMethod(name = {"union", "+", "|"})
    public IRubyObject union(ThreadContext context, IRubyObject other) {
        BitSet data = (BitSet) bits.clone();
        data.or(operand(context, other));
        return result(context, data);
    }

    @JRubyMethod(name = {"intersection", "&"})
    public IRubyObject intersection(ThreadContext context, IRubyObject other) {
        BitSet data = (BitSet) bits.clone();
        data.and(operand(context, other));
        return result(context, data);
    }

    @JRubyMethod(name = {"difference", "-"})
    public IRubyObject difference(ThreadContext context, IRubyObject other) {
        BitSet data = (BitSet) bits.clone();
        data.andNot(operand(context, other));
        return result(context, data);
    }

    @JRubyMethod(name = "^")
    public IRubyObject exclusion(ThreadContext context, IRubyObject other) {
        BitSet data = (BitSet) bits.clone();
        data.xor(operand(context, other));
        return result(context, data);
    }

    @JRubyMethod(name = "intersect?")
    public IRubyObject intersects(ThreadContext context, IRubyObject other) {
        return context.runtime.newBoolean(bits.intersects(operand(context, other)));
    }

    @JRubyMethod(name = "disjoint?")
    public IRubyObject disjoint(ThreadContext context, IRubyObject other) {
        return context.runtime.newBoolean(!bits.intersects(operand(context, other)));
    }

    private static boolean subset(BitSet a, BitSet b) {
        BitSet remainder = (BitSet) a.clone();
        remainder.andNot(b);
        return remainder.isEmpty();
    }

    @JRubyMethod(name = {"subset?", "<="})
    public IRubyObject subsetOf(ThreadContext context, IRubyObject other) {
        return context.runtime.newBoolean(subset(bits, operand(context, other)));
    }

    @JRubyMethod(name = {"proper_subset?", "<"})
    public IRubyObject properSubsetOf(ThreadContext context, IRubyObject other) {
        BitSet data = operand(context, other);
        return context.runtime.newBoolean(!bits.equals(data) && subset(bits, data));
    }

    @JRubyMethod(name = {"superset?", ">="})
    public IRubyObject supersetOf(ThreadContext context, IRubyObject other) {
        return context.runtime.newBoolean(subset(operand(context, other), bits));
    }

    @JRubyMethod(name = {"proper_superset?", ">"})
    public IRubyObject properSupersetOf(ThreadContext context, IRubyObject other) {
        BitSet data = operand(context, other);
        return context.runtime.newBoolean(!bits.equals(data) && subset(data, bits));
    }

    @JRubyMethod(name = "==")
    public IRubyObject equalValue(ThreadContext context, IRubyObject other) {
        return context.runtime.newBoolean(characterSet(context, other) && bits.equals(operand(context, other)));
    }

    @JRubyMethod(name = "eql?")
    public IRubyObject eql(ThreadContext context, IRubyObject other) {
        return context.runtime.newBoolean(other instanceof RubyCharacterSet
                && bits.equals(((RubyCharacterSet) other).bits));
    }

    @JRubyMethod(name = "hash")
    public IRubyObject contentHash(ThreadContext context) {
        return context.runtime.newFixnum(bits.hashCode());
    }

    @JRubyMethod(name = "<=>")
    public IRubyObject compare(ThreadContext context, IRubyObject other) {
        if (!characterSet(context, other)) return context.nil;
        BitSet data = operand(context, other);
        if (bits.equals(data)) return context.runtime.newFixnum(0);
        if (subset(bits, data)) return context.runtime.newFixnum(-1);
        if (subset(data, bits)) return context.runtime.newFixnum(1);
        return context.nil;
    }

    @JRubyMethod(name = "each")
    public IRubyObject each(ThreadContext context, Block block) {
        if (!block.isGiven()) return enumerator(context, "each");
        // Snapshot iteration permits mutation during Ruby callbacks without sharing state.
        BitSet snapshot = (BitSet) bits.clone();
        for (int cp = snapshot.nextSetBit(0); cp >= 0; cp = snapshot.nextSetBit(cp + 1)) {
            block.yield(context, context.runtime.newFixnum(cp));
        }
        return this;
    }

    private IRubyObject filter(ThreadContext context, Block block, boolean keep) {
        if (!block.isGiven()) return enumerator(context, keep ? "keep_if" : "delete_if");
        checkFrozen();
        BitSet snapshot = (BitSet) bits.clone();
        for (int cp = snapshot.nextSetBit(0); cp >= 0; cp = snapshot.nextSetBit(cp + 1)) {
            boolean accepted = block.yield(context, context.runtime.newFixnum(cp)).isTrue();
            if (accepted != keep) {
                checkFrozen();
                bits.clear(cp);
            }
        }
        return this;
    }

    @JRubyMethod(name = "keep_if")
    public IRubyObject keepIf(ThreadContext context, Block block) {
        return filter(context, block, true);
    }

    @JRubyMethod(name = "delete_if")
    public IRubyObject deleteIf(ThreadContext context, Block block) {
        return filter(context, block, false);
    }

    @JRubyMethod(name = "to_a", optional = 1)
    public IRubyObject toArray(ThreadContext context, IRubyObject[] args) {
        RubyArray<?> array = context.runtime.newArray(bits.cardinality());
        boolean stringify = args.length > 0 && args[0].isTrue();
        for (int cp = bits.nextSetBit(0); cp >= 0; cp = bits.nextSetBit(cp + 1)) {
            array.append(stringify ? StringOperations.character(context, cp) : context.runtime.newFixnum(cp));
        }
        return array;
    }

    @JRubyMethod(name = "min")
    public IRubyObject min(ThreadContext context) {
        int cp = bits.nextSetBit(0);
        return cp < 0 ? context.nil : context.runtime.newFixnum(cp);
    }

    @JRubyMethod(name = "max")
    public IRubyObject max(ThreadContext context) {
        int cp = bits.length() - 1;
        return cp < 0 ? context.nil : context.runtime.newFixnum(cp);
    }

    @JRubyMethod(name = "minmax")
    public IRubyObject minmax(ThreadContext context) {
        return context.runtime.newArray(min(context), max(context));
    }

    @JRubyMethod(name = "ranges")
    public IRubyObject ranges(ThreadContext context) {
        RubyArray<?> array = context.runtime.newArray();
        for (int from = bits.nextSetBit(0); from >= 0;) {
            int end = bits.nextClearBit(from);
            array.append(RubyRange.newRange(context,
                    context.runtime.newFixnum(from), context.runtime.newFixnum(end - 1), false));
            from = bits.nextSetBit(end);
        }
        return array;
    }

    @JRubyMethod(name = "sample", optional = 1)
    public IRubyObject sample(ThreadContext context, IRubyObject[] args) {
        IRubyObject array = toArray(context, new IRubyObject[] {context.tru});
        return array.callMethod(context, "sample", args);
    }

    @JRubyMethod(name = "from_ranges", meta = true, rest = true)
    public static IRubyObject fromRanges(ThreadContext context, IRubyObject klass, IRubyObject[] ranges) {
        RubyCharacterSet set = construct(context, klass);
        for (IRubyObject range : ranges) {
            if (!(range instanceof RubyRange)) throw context.runtime.newArgumentError("pass a Range");
            set.mergeRange(context, (RubyRange) range);
        }
        return set;
    }

    @JRubyMethod(name = "ext_section", required = 2)
    public IRubyObject section(ThreadContext context, IRubyObject from, IRubyObject upto) {
        int start = codepoint(context, from);
        int end = codepoint(context, upto);
        BitSet data = (BitSet) bits.clone();
        data.clear(0, start);
        data.clear(end + 1, Math.max(end + 1, data.length()));
        return result(context, data);
    }

    private int sectionCount(ThreadContext context, IRubyObject from, IRubyObject upto) {
        int start = codepoint(context, from);
        int end = codepoint(context, upto);
        return start > end ? 0 : bits.get(start, end + 1).cardinality();
    }

    @JRubyMethod(name = "ext_count_in_section", required = 2)
    public IRubyObject countSection(ThreadContext context, IRubyObject from, IRubyObject upto) {
        return context.runtime.newFixnum(sectionCount(context, from, upto));
    }

    @JRubyMethod(name = "ext_section?", required = 2)
    public IRubyObject hasSection(ThreadContext context, IRubyObject from, IRubyObject upto) {
        int start = codepoint(context, from);
        int end = codepoint(context, upto);
        int first = bits.nextSetBit(start);
        return context.runtime.newBoolean(first >= 0 && first <= end);
    }

    @JRubyMethod(name = "ext_section_ratio", required = 2)
    public IRubyObject sectionRatio(ThreadContext context, IRubyObject from, IRubyObject upto) {
        return context.runtime.newFloat((double) sectionCount(context, from, upto) / bits.cardinality());
    }

    @JRubyMethod(name = "planes")
    public IRubyObject planes(ThreadContext context) {
        RubyArray<?> array = context.runtime.newArray();
        for (int cp = bits.nextSetBit(0); cp >= 0;) {
            int plane = cp >>> 16;
            array.append(context.runtime.newFixnum(plane));
            cp = bits.nextSetBit((plane + 1) << 16);
        }
        return array;
    }

    private static int planeNumber(ThreadContext context, IRubyObject number) {
        int plane = codepoint(context, number);
        if (plane > 16) throw context.runtime.newArgumentError("plane must be between 0 and 16");
        return plane;
    }

    @JRubyMethod(name = "plane")
    public IRubyObject plane(ThreadContext context, IRubyObject number) {
        int start = planeNumber(context, number) << 16;
        return section(context, context.runtime.newFixnum(start), context.runtime.newFixnum(start + 0xFFFF));
    }

    @JRubyMethod(name = "member_in_plane?")
    public IRubyObject hasPlane(ThreadContext context, IRubyObject number) {
        int start = planeNumber(context, number) << 16;
        int first = bits.nextSetBit(start);
        return context.runtime.newBoolean(first >= 0 && first < start + 0x10000);
    }

    @JRubyMethod(name = "ext_inversion", required = 2)
    public IRubyObject inversion(ThreadContext context, IRubyObject includeSurrogates, IRubyObject upto) {
        int end = codepoint(context, upto);
        BitSet data = bits.get(0, end + 1);
        data.flip(0, end + 1);
        if (!includeSurrogates.isTrue()) data.clear(0xD800, 0xE000);
        return result(context, data);
    }

    @JRubyMethod(name = "case_insensitive")
    public IRubyObject caseInsensitive(ThreadContext context) {
        BitSet data = (BitSet) bits.clone();
        // Flags 0 exclude multi-character folds; the API supplies both directions.
        UTF8Encoding.INSTANCE.applyAllCaseFold(0, (from, to, length, ignored) -> {
            if (length == 1 && bits.get(from)) data.set(to[0]);
        }, null);
        return result(context, data);
    }

    @JRubyMethod(name = "allocated_length")
    public IRubyObject allocatedLength(ThreadContext context) {
        return context.runtime.newFixnum(bits.size());
    }

    @JRubyMethod(name = "of_string", meta = true)
    public static IRubyObject ofString(ThreadContext context, IRubyObject klass, IRubyObject string) {
        RubyCharacterSet set = construct(context, klass);
        StringOperations.populate(context, string, set.bits);
        return set;
    }

    @JRubyMethod(name = "count_in")
    public IRubyObject countIn(ThreadContext context, IRubyObject string) {
        return StringOperations.query(context, string, bits, StringOperations.COUNT);
    }

    @JRubyMethod(name = "cover?")
    public IRubyObject covers(ThreadContext context, IRubyObject string) {
        return StringOperations.query(context, string, bits, StringOperations.COVER);
    }

    @JRubyMethod(name = "used_by?")
    public IRubyObject usedBy(ThreadContext context, IRubyObject string) {
        return StringOperations.query(context, string, bits, StringOperations.ANY);
    }

    @JRubyMethod(name = "scan")
    public IRubyObject scan(ThreadContext context, IRubyObject string) {
        return StringOperations.scan(context, string, bits);
    }

    @JRubyMethod(name = "delete_in")
    public IRubyObject deleteIn(ThreadContext context, IRubyObject string) {
        return StringOperations.filter(context, string, bits, false, false);
    }

    @JRubyMethod(name = "delete_in!")
    public IRubyObject deleteInPlace(ThreadContext context, IRubyObject string) {
        return StringOperations.filter(context, string, bits, false, true);
    }

    @JRubyMethod(name = "keep_in")
    public IRubyObject keepIn(ThreadContext context, IRubyObject string) {
        return StringOperations.filter(context, string, bits, true, false);
    }

    @JRubyMethod(name = "keep_in!")
    public IRubyObject keepInPlace(ThreadContext context, IRubyObject string) {
        return StringOperations.filter(context, string, bits, true, true);
    }
}
