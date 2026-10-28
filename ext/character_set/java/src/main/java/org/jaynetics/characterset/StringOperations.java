package org.jaynetics.characterset;

import java.util.Arrays;
import java.util.BitSet;
import org.jcodings.Encoding;
import org.jcodings.specific.ASCIIEncoding;
import org.jcodings.specific.UTF8Encoding;
import org.jruby.RubyArray;
import org.jruby.RubyString;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.util.ByteList;

final class StringOperations {
    static final int COUNT = 0;
    static final int COVER = 1;
    static final int ANY = 2;

    private static RubyString string(ThreadContext context, IRubyObject value) {
        if (!(value instanceof RubyString)) throw context.runtime.newArgumentError("pass a String");
        return (RubyString) value;
    }

    private static RubyString unicode(ThreadContext context, RubyString string) {
        Encoding encoding = string.getEncoding();
        if (encoding == UTF8Encoding.INSTANCE || encoding == ASCIIEncoding.INSTANCE
                || (encoding.isAsciiCompatible() && string.isAsciiOnly())) return string;
        return (RubyString) string.encode(context,
                context.runtime.getEncodingService().getEncoding(UTF8Encoding.INSTANCE));
    }

    private static int width(ThreadContext context, byte[] bytes, int position, int end, boolean binary) {
        if (binary || bytes[position] >= 0) return 1;
        int length = UTF8Encoding.INSTANCE.length(bytes, position, end);
        if (length <= 0) throw context.runtime.newArgumentError("invalid byte sequence in UTF-8");
        return length;
    }

    private static int codepoint(byte[] bytes, int position, int length) {
        if (length == 1) return bytes[position] & 255;
        return UTF8Encoding.INSTANCE.mbcToCode(bytes, position, position + length);
    }

    static RubyString character(ThreadContext context, int cp) {
        // Delegate UTF-8 character construction, including surrogate policy, to Ruby.
        return (RubyString) context.runtime.newFixnum(cp).chr(context,
                context.runtime.getEncodingService().getEncoding(UTF8Encoding.INSTANCE));
    }

    static void populate(ThreadContext context, IRubyObject value, BitSet bits) {
        RubyString input = unicode(context, string(context, value));
        ByteList data = input.getByteList();
        byte[] bytes = data.getUnsafeBytes();
        int end = data.getBegin() + data.realSize();
        boolean binary = input.getEncoding() == ASCIIEncoding.INSTANCE;
        for (int p = data.getBegin(); p < end;) {
            int length = width(context, bytes, p, end, binary);
            bits.set(codepoint(bytes, p, length));
            p += length;
        }
    }

    static IRubyObject query(ThreadContext context, IRubyObject value, BitSet bits, int operation) {
        RubyString input = unicode(context, string(context, value));
        ByteList data = input.getByteList();
        byte[] bytes = data.getUnsafeBytes();
        int end = data.getBegin() + data.realSize();
        boolean binary = input.getEncoding() == ASCIIEncoding.INSTANCE;
        int count = 0;
        for (int p = data.getBegin(); p < end;) {
            int length = width(context, bytes, p, end, binary);
            boolean found = bits.get(codepoint(bytes, p, length));
            if (operation == COVER && !found) return context.fals;
            if (operation == ANY && found) return context.tru;
            if (found) count++;
            p += length;
        }
        if (operation == COUNT) return context.runtime.newFixnum(count);
        return context.runtime.newBoolean(operation == COVER);
    }

    static IRubyObject scan(ThreadContext context, IRubyObject value, BitSet bits) {
        RubyString input = unicode(context, string(context, value));
        ByteList data = input.getByteList();
        byte[] bytes = data.getUnsafeBytes();
        int end = data.getBegin() + data.realSize();
        boolean binary = input.getEncoding() == ASCIIEncoding.INSTANCE;
        RubyArray<?> result = context.runtime.newArray();
        for (int p = data.getBegin(); p < end;) {
            int length = width(context, bytes, p, end, binary);
            int cp = codepoint(bytes, p, length);
            if (bits.get(cp)) {
                result.append(binary ? character(context, cp) : RubyString.newStringNoCopy(context.runtime,
                        Arrays.copyOfRange(bytes, p, p + length), 0, length, UTF8Encoding.INSTANCE));
            }
            p += length;
        }
        return result;
    }

    static IRubyObject filter(ThreadContext context, IRubyObject value, BitSet bits, boolean keep, boolean bang) {
        RubyString original = string(context, value);
        if (bang) original.modifyCheck();
        RubyString input = unicode(context, original);
        ByteList data = input.getByteList();
        byte[] bytes = data.getUnsafeBytes();
        int begin = data.getBegin();
        int end = begin + data.realSize();
        boolean binary = input.getEncoding() == ASCIIEncoding.INSTANCE;
        byte[] output = null;
        int written = 0;
        int span = begin;
        for (int p = begin; p < end;) {
            int length = width(context, bytes, p, end, binary);
            if (bits.get(codepoint(bytes, p, length)) != keep) {
                if (output == null) output = new byte[data.realSize()];
                int retained = p - span;
                System.arraycopy(bytes, span, output, written, retained);
                written += retained;
                span = p + length;
            }
            p += length;
        }
        if (output == null) return bang ? context.nil : original.strDup(context.runtime);
        System.arraycopy(bytes, span, output, written, end - span);
        written += end - span;
        RubyString result = RubyString.newStringNoCopy(context.runtime, output, 0, written, input.getEncoding());
        if (input.getEncoding() != original.getEncoding()) {
            result = (RubyString) result.encode(context,
                    context.runtime.getEncodingService().getEncoding(original.getEncoding()));
        }
        if (!bang) return result;
        original.replace(result);
        return original;
    }

    private StringOperations() {}
}
