#include "ruby.h"
#include "ruby/encoding.h"
#include "unicode_casefold_table.h"

#define SETBIT(byte_arr, bit) (byte_arr[bit >> 3] |= (1 << (bit & 0x07)))
#define CLRBIT(byte_arr, bit) (byte_arr[bit >> 3] &= ~(1 << (bit & 0x07)))
#define TSTBIT(byte_arr, bit) (byte_arr[bit >> 3] & (1 << (bit & 0x07)))

#define UNICODE_PLANE_SIZE 0x10000
#define UNICODE_PLANE_COUNT 17
#define UNICODE_CP_COUNT (UNICODE_PLANE_SIZE * UNICODE_PLANE_COUNT)
#define UNICODE_TOTAL_BYTES (UNICODE_CP_COUNT / 8)

#define CPS_MEMSIZE (sizeof(cp_byte) * UNICODE_TOTAL_BYTES)

typedef char cp_byte;
typedef unsigned long cp_index;

struct character_set_data
{
  cp_byte *cps;
};

static void
free_character_set(void *ptr)
{
  struct character_set_data *data = ptr;
  ruby_xfree(data->cps);
  ruby_xfree(data);
}

static size_t
memsize_character_set(const void *ptr)
{
  const struct character_set_data *data = ptr;
  return sizeof(*data) + CPS_MEMSIZE;
}

static const rb_data_type_t character_set_type = {
    .wrap_struct_name = "character_set",
    .function = {
        .dmark = NULL,
        .dfree = free_character_set,
        .dsize = memsize_character_set,
    },
    .data = NULL,
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

static inline VALUE
alloc_cset(VALUE klass, cp_byte *cps)
{
  VALUE set;
  struct character_set_data *data;
  set = TypedData_Make_Struct(klass, struct character_set_data, &character_set_type, data);
  data->cps = cps;
  return set;
}

static inline cp_byte *
fetch_cps(VALUE set)
{
  struct character_set_data *data;
  TypedData_Get_Struct(set, struct character_set_data, &character_set_type, data);
  return data->cps;
}

static inline cp_byte *
alloc_cps()
{
  cp_byte *cps;
  cps = ruby_xmalloc(CPS_MEMSIZE);
  memset(cps, 0, CPS_MEMSIZE);
  return cps;
}

static VALUE
method_allocate(VALUE self)
{
  return alloc_cset(self, alloc_cps());
}

#define FOR_EACH_ACTIVE_CODEPOINT(action)   \
  cp_index cp;                              \
  cp_byte *cps;                             \
  cps = fetch_cps(self);                    \
  for (cp = 0; cp < UNICODE_CP_COUNT; cp++) \
  {                                         \
    if (TSTBIT(cps, cp))                    \
    {                                       \
      action;                               \
    }                                       \
  }

// ***************************
// `Set` compatibility methods
// ***************************

static inline cp_index
active_cp_count(VALUE self)
{
  cp_index count;
  count = 0;
  FOR_EACH_ACTIVE_CODEPOINT(count++);
  return count;
}

static VALUE
method_length(VALUE self)
{
  return LONG2FIX(active_cp_count(self));
}

static inline VALUE
enumerator_length(VALUE self, VALUE args, VALUE eobj)
{
  return LONG2FIX(active_cp_count(self));
}

static VALUE
method_each(VALUE self)
{
  RETURN_SIZED_ENUMERATOR(self, 0, 0, enumerator_length);
  FOR_EACH_ACTIVE_CODEPOINT(rb_yield(LONG2FIX(cp)));
  return self;
}

// returns an Array of codepoint Integers by default.
// returns an Array of Strings of length 1 if passed `true`.
static VALUE
method_to_a(int argc, VALUE *argv, VALUE self)
{
  VALUE arr;
  rb_encoding *enc;
  rb_check_arity(argc, 0, 1);

  arr = rb_ary_new();
  if (!argc || NIL_P(argv[0]) || argv[0] == Qfalse)
  {
    FOR_EACH_ACTIVE_CODEPOINT(rb_ary_push(arr, LONG2FIX(cp)));
  }
  else
  {
    enc = rb_utf8_encoding();
    FOR_EACH_ACTIVE_CODEPOINT(rb_ary_push(arr, rb_enc_uint_chr((int)cp, enc)));
  }

  return arr;
}

static VALUE
method_empty_p(VALUE self)
{
  FOR_EACH_ACTIVE_CODEPOINT(return Qfalse);
  return Qtrue;
}

static VALUE
method_hash(VALUE self)
{
  cp_index cp, hash, four_byte_value;
  cp_byte *cps;
  cps = fetch_cps(self);

  hash = 17;
  for (cp = 0; cp < UNICODE_CP_COUNT; cp++)
  {
    if (cp % 32 == 0)
    {
      if (cp != 0)
      {
        hash = hash * 23 + four_byte_value;
      }
      four_byte_value = 0;
    }
    if (TSTBIT(cps, cp))
    {
      four_byte_value++;
    }
  }

  return LONG2FIX(hash);
}

static inline VALUE
delete_if_block_result(VALUE self, int truthy)
{
  VALUE result;
  rb_need_block();
  rb_check_frozen(self);
  FOR_EACH_ACTIVE_CODEPOINT(
      result = rb_yield(LONG2FIX(cp));
      if ((NIL_P(result) || result == Qfalse) != truthy) CLRBIT(cps, cp););
  return self;
}

static VALUE
method_delete_if(VALUE self)
{
  RETURN_SIZED_ENUMERATOR(self, 0, 0, enumerator_length);
  return delete_if_block_result(self, 1);
}

static VALUE
method_keep_if(VALUE self)
{
  RETURN_SIZED_ENUMERATOR(self, 0, 0, enumerator_length);
  return delete_if_block_result(self, 0);
}

static VALUE
method_clear(VALUE self)
{
  cp_index cp;
  cp_byte *cps;
  rb_check_frozen(self);
  cps = fetch_cps(self);
  for (cp = 0; cp < UNICODE_CP_COUNT; cp++)
  {
    CLRBIT(cps, cp);
  }
  return self;
}

#define RETURN_NEW_SET_BASED_ON(condition)  \
  cp_index cp;                              \
  cp_byte *a, *b, *new_cps;                 \
  a = fetch_cps(self);                      \
  if (other)                                \
  {                                         \
    b = fetch_cps(other);                   \
  }                                         \
  new_cps = alloc_cps();                    \
  for (cp = 0; cp < UNICODE_CP_COUNT; cp++) \
  {                                         \
    if (condition)                          \
    {                                       \
      SETBIT(new_cps, cp);                  \
    }                                       \
  }                                         \
  return alloc_cset(RBASIC(self)->klass, new_cps);

static VALUE
method_intersection(VALUE self, VALUE other)
{
  RETURN_NEW_SET_BASED_ON(TSTBIT(a, cp) && TSTBIT(b, cp));
}

static VALUE
method_exclusion(VALUE self, VALUE other)
{
  RETURN_NEW_SET_BASED_ON(TSTBIT(a, cp) ^ TSTBIT(b, cp));
}

static VALUE
method_union(VALUE self, VALUE other)
{
  RETURN_NEW_SET_BASED_ON(TSTBIT(a, cp) || TSTBIT(b, cp));
}

static VALUE
method_difference(VALUE self, VALUE other)
{
  RETURN_NEW_SET_BASED_ON(TSTBIT(a, cp) > TSTBIT(b, cp));
}

static VALUE
method_include_p(VALUE self, VALUE num)
{
  cp_byte *cps;
  cps = fetch_cps(self);
  return (TSTBIT(cps, FIX2ULONG(num)) ? Qtrue : Qfalse);
}

static inline int
toggle_codepoint(VALUE set, VALUE cp_num, unsigned int on, int check_if_noop)
{
  cp_index cp;
  cp_byte *cps;
  rb_check_frozen(set);
  cps = fetch_cps(set);
  cp = FIX2ULONG(cp_num);
  if (check_if_noop && (!TSTBIT(cps, cp) == !on))
  {
    return 0;
  }
  else
  {
    if (on)
    {
      SETBIT(cps, cp);
    }
    else
    {
      CLRBIT(cps, cp);
    }
    return 1;
  }
}

static VALUE
method_add(VALUE self, VALUE cp_num)
{
  return toggle_codepoint(self, cp_num, 1, 0) ? self : Qnil;
}

static VALUE
method_add_p(VALUE self, VALUE cp_num)
{
  return toggle_codepoint(self, cp_num, 1, 1) ? self : Qnil;
}

static VALUE
method_delete(VALUE self, VALUE cp_num)
{
  return toggle_codepoint(self, cp_num, 0, 0) ? self : Qnil;
}

static VALUE
method_delete_p(VALUE self, VALUE cp_num)
{
  return toggle_codepoint(self, cp_num, 0, 1) ? self : Qnil;
}

#define COMPARE_SETS(action)                \
  cp_index cp;                              \
  cp_byte *cps, *other_cps;                 \
  cps = fetch_cps(self);                    \
  other_cps = fetch_cps(other);             \
  for (cp = 0; cp < UNICODE_CP_COUNT; cp++) \
  {                                         \
    action;                                 \
  }

static VALUE
method_intersect_p(VALUE self, VALUE other)
{
  COMPARE_SETS(if (TSTBIT(cps, cp) && TSTBIT(other_cps, cp)) return Qtrue);
  return Qfalse;
}

static VALUE
method_disjoint_p(VALUE self, VALUE other)
{
  return method_intersect_p(self, other) ? Qfalse : Qtrue;
}

static inline int
is_character_set(VALUE obj)
{
  return rb_typeddata_is_kind_of(obj, &character_set_type);
}

static VALUE
method_eql_p(VALUE self, VALUE other)
{
  if (!is_character_set(other))
  {
    return Qfalse;
  }
  if (self == other) // same object_id
  {
    return Qtrue;
  }

  COMPARE_SETS(if (TSTBIT(cps, cp) != TSTBIT(other_cps, cp)) return Qfalse);

  return Qtrue;
}

static inline VALUE
merge_character_set(VALUE self, VALUE other)
{
  COMPARE_SETS(if (TSTBIT(other_cps, cp)) SETBIT(cps, cp));
  return self;
}

static inline void
raise_arg_err_unless_valid_as_cp(VALUE object_id)
{
  if (FIXNUM_P(object_id) && object_id > 0 && object_id < 0x220001)
  {
    return;
  }
  rb_raise(rb_eArgError, "CharacterSet members must be between 0 and 0x10FFFF");
}

static inline VALUE
merge_rb_range(VALUE self, VALUE rb_range)
{
  VALUE from_id, upto_id;
  int excl;
  cp_index cp;
  cp_byte *cps;
  cps = fetch_cps(self);

  if (!RTEST(rb_range_values(rb_range, &from_id, &upto_id, &excl)))
  {
    rb_raise(rb_eArgError, "pass a Range");
  }
  if (excl)
  {
    upto_id -= 2;
  }

  raise_arg_err_unless_valid_as_cp(from_id);
  raise_arg_err_unless_valid_as_cp(upto_id);

  for (/* */; from_id <= upto_id; from_id += 2)
  {
    cp = FIX2ULONG(from_id);
    SETBIT(cps, cp);
  }
  return self;
}

static inline VALUE
merge_rb_array(VALUE self, VALUE rb_array)
{
  VALUE el;
  cp_byte *cps;
  VALUE array_length, i;
  cps = fetch_cps(self);
  Check_Type(rb_array, T_ARRAY);
  array_length = RARRAY_LEN(rb_array);
  for (i = 0; i < array_length; i++)
  {
    el = RARRAY_AREF(rb_array, i);
    raise_arg_err_unless_valid_as_cp(el);
    SETBIT(cps, FIX2ULONG(el));
  }
  return self;
}

static VALUE
method_merge(VALUE self, VALUE other)
{
  rb_check_frozen(self);
  if (is_character_set(other))
  {
    return merge_character_set(self, other);
  }
  else if (TYPE(other) == T_ARRAY)
  {
    return merge_rb_array(self, other);
  }
  return merge_rb_range(self, other);
}

static VALUE
method_initialize_copy(VALUE self, VALUE other)
{
  merge_character_set(self, other);
  return other;
}

static VALUE
method_subtract(VALUE self, VALUE other)
{
  rb_check_frozen(self);
  COMPARE_SETS(if (TSTBIT(other_cps, cp)) CLRBIT(cps, cp));
  return self;
}

static inline int
a_subset_of_b(VALUE set_a, VALUE set_b, int *is_proper)
{
  cp_byte *cps_a, *cps_b;
  cp_index cp, size_a, size_b;

  if (!is_character_set(set_a) || !is_character_set(set_b))
  {
    rb_raise(rb_eArgError, "pass a CharacterSet");
  }

  cps_a = fetch_cps(set_a);
  cps_b = fetch_cps(set_b);

  *is_proper = 0;
  size_a = 0;
  size_b = 0;

  for (cp = 0; cp < UNICODE_CP_COUNT; cp++)
  {
    if (TSTBIT(cps_a, cp))
    {
      if (!TSTBIT(cps_b, cp))
      {
        return 0;
      }
      size_a++;
      size_b++;
    }
    else if (TSTBIT(cps_b, cp))
    {
      size_b++;
    }
  }

  if (size_b > size_a)
  {
    *is_proper = 1;
  }

  return 1;
}

static VALUE
method_subset_p(VALUE self, VALUE other)
{
  int is_proper;
  return a_subset_of_b(self, other, &is_proper) ? Qtrue : Qfalse;
}

static VALUE
method_proper_subset_p(VALUE self, VALUE other)
{
  int is, is_proper;
  is = a_subset_of_b(self, other, &is_proper);
  return (is && is_proper) ? Qtrue : Qfalse;
}

static VALUE
method_superset_p(VALUE self, VALUE other)
{
  int is_proper;
  return a_subset_of_b(other, self, &is_proper) ? Qtrue : Qfalse;
}

static VALUE
method_proper_superset_p(VALUE self, VALUE other)
{
  int is, is_proper;
  is = a_subset_of_b(other, self, &is_proper);
  return (is && is_proper) ? Qtrue : Qfalse;
}

// *******************************
// `CharacterSet`-specific methods
// *******************************

static VALUE
class_method_from_ranges(VALUE self, VALUE ranges)
{
  VALUE new_set, range_count, i;
  new_set = rb_class_new_instance(0, 0, self);
  range_count = RARRAY_LEN(ranges);
  for (i = 0; i < range_count; i++)
  {
    merge_rb_range(new_set, RARRAY_AREF(ranges, i));
  }
  return new_set;
}

static VALUE
method_ranges(VALUE self)
{
  VALUE ranges, codepoint, previous_codepoint, current_start, current_end;

  ranges = rb_ary_new();
  previous_codepoint = 0;
  current_start = 0;
  current_end = 0;

  FOR_EACH_ACTIVE_CODEPOINT(
      codepoint = LONG2FIX(cp);

      if (!previous_codepoint) {
        current_start = codepoint;
      } else if (previous_codepoint + 2 != codepoint) {
        // gap found, finalize previous range
        rb_ary_push(ranges, rb_range_new(current_start, current_end, 0));
        current_start = codepoint;
      } current_end = codepoint;
      previous_codepoint = codepoint;);

  // add final range
  if (current_start)
  {
    rb_ary_push(ranges, rb_range_new(current_start, current_end, 0));
  }

  return ranges;
}

static VALUE
method_sample(int argc, VALUE *argv, VALUE self)
{
  VALUE to_a_args[1], array;
  rb_check_arity(argc, 0, 1);
  to_a_args[0] = Qtrue;
  array = method_to_a(1, to_a_args, self);
  return rb_funcall(array, rb_intern("sample"), argc, argc ? argv[0] : 0);
}

static inline VALUE
new_set_from_section(VALUE set, cp_index from, cp_index upto)
{
  cp_byte *cps, *new_cps;
  cp_index cp;
  cps = fetch_cps(set);
  new_cps = alloc_cps();
  for (cp = from; cp <= upto; cp++)
  {
    if (TSTBIT(cps, cp))
    {
      SETBIT(new_cps, cp);
    }
  }
  return alloc_cset(RBASIC(set)->klass, new_cps);
}

static inline cp_index
active_cp_count_in_section(VALUE set, cp_index from, cp_index upto)
{
  cp_byte *cps;
  cp_index cp, count;
  cps = fetch_cps(set);
  for (count = 0, cp = from; cp <= upto; cp++)
  {
    if (TSTBIT(cps, cp))
    {
      count++;
    }
  }
  return count;
}

static inline VALUE
has_cp_in_section(VALUE set, cp_index from, cp_index upto)
{
  cp_byte *cps;
  cp_index cp;
  cps = fetch_cps(set);
  for (cp = from; cp <= upto; cp++)
  {
    if (TSTBIT(cps, cp))
    {
      return Qtrue;
    }
  }
  return Qfalse;
}

static inline VALUE
ratio_of_section(VALUE set, cp_index from, cp_index upto)
{
  double section_count, total_count;
  section_count = (double)active_cp_count_in_section(set, from, upto);
  total_count = (double)active_cp_count(set);
  return DBL2NUM(section_count / total_count);
}

#define MAX_CP 0x10FFFF
#define MAX_ASCII_CP 0x7F
#define MAX_BMP_CP 0xFFFF
#define MIN_ASTRAL_CP 0x10000

static VALUE
method_ascii_part(VALUE self)
{
  return new_set_from_section(self, 0, MAX_ASCII_CP);
}

static VALUE
method_ascii_part_p(VALUE self)
{
  return has_cp_in_section(self, 0, MAX_ASCII_CP);
}

static VALUE
method_ascii_only_p(VALUE self)
{
  return has_cp_in_section(self, MAX_ASCII_CP + 1, MAX_CP) ? Qfalse : Qtrue;
}

static VALUE
method_ascii_ratio(VALUE self)
{
  return ratio_of_section(self, 0, MAX_ASCII_CP);
}

static VALUE
method_bmp_part(VALUE self)
{
  return new_set_from_section(self, 0, MAX_BMP_CP);
}

static VALUE
method_bmp_part_p(VALUE self)
{
  return has_cp_in_section(self, 0, MAX_BMP_CP);
}

static VALUE
method_bmp_only_p(VALUE self)
{
  return has_cp_in_section(self, MIN_ASTRAL_CP, MAX_CP) ? Qfalse : Qtrue;
}

static VALUE
method_bmp_ratio(VALUE self)
{
  return ratio_of_section(self, 0, MAX_BMP_CP);
}

static VALUE
method_astral_part(VALUE self)
{
  return new_set_from_section(self, MIN_ASTRAL_CP, MAX_CP);
}

static VALUE
method_astral_part_p(VALUE self)
{
  return has_cp_in_section(self, MIN_ASTRAL_CP, MAX_CP);
}

static VALUE
method_astral_only_p(VALUE self)
{
  return has_cp_in_section(self, 0, MAX_BMP_CP) ? Qfalse : Qtrue;
}

static VALUE
method_astral_ratio(VALUE self)
{
  return ratio_of_section(self, MIN_ASTRAL_CP, MAX_CP);
}

static inline VALUE
set_has_member_in_plane(VALUE set, unsigned int plane)
{
  cp_byte *cps;
  cp_index cp, max_cp;
  cps = fetch_cps(set);
  cp = plane * UNICODE_PLANE_SIZE;
  max_cp = (plane + 1) * MAX_BMP_CP;
  for (/* */; cp <= max_cp; cp++)
  {
    if (TSTBIT(cps, cp))
    {
      return Qtrue;
    }
  }
  return Qfalse;
}

static VALUE
method_planes(VALUE self)
{
  unsigned int i;
  VALUE planes;
  planes = rb_ary_new();
  for (i = 0; i < UNICODE_PLANE_COUNT; i++)
  {
    if (set_has_member_in_plane(self, i))
    {
      rb_ary_push(planes, INT2FIX(i));
    }
  }
  return planes;
}

static inline int
valid_plane_num(VALUE num)
{
  int plane;
  Check_Type(num, T_FIXNUM);
  plane = FIX2INT(num);
  if (plane < 0 || plane >= UNICODE_PLANE_COUNT)
  {
    rb_raise(rb_eArgError, "plane must be between 0 and %d", UNICODE_PLANE_COUNT - 1);
  }
  return plane;
}

static VALUE
method_plane(VALUE self, VALUE plane_num)
{
  cp_index plane, plane_beg, plane_end;
  plane = valid_plane_num(plane_num);
  plane_beg = plane * UNICODE_PLANE_SIZE;
  plane_end = (plane + 1) * MAX_BMP_CP;
  return new_set_from_section(self, plane_beg, plane_end);
}

static VALUE
method_member_in_plane_p(VALUE self, VALUE plane_num)
{
  unsigned int plane;
  plane = valid_plane_num(plane_num);
  return set_has_member_in_plane(self, plane);
}

#define NON_SURROGATE(cp) (cp > 0xDFFF || cp < 0xD800)

static VALUE
method_ext_inversion(int argc, VALUE *argv, VALUE self)
{
  int include_surrogates;
  cp_index upto;
  VALUE other;
  other = 0;
  rb_check_arity(argc, 0, 2);
  include_surrogates = ((argc > 0) && (argv[0] == Qtrue));
  if ((argc > 1) && FIXNUM_P(argv[1]))
  {
    upto = FIX2ULONG(argv[1]);
    RETURN_NEW_SET_BASED_ON(
        cp <= upto && !TSTBIT(a, cp) && (include_surrogates || NON_SURROGATE(cp)));
  }
  RETURN_NEW_SET_BASED_ON(
      !TSTBIT(a, cp) && (include_surrogates || NON_SURROGATE(cp)));
}

typedef int (*str_cp_handler)(unsigned int, cp_byte *, VALUE *memo);

static inline int
add_str_cp_to_arr(unsigned int str_cp, cp_byte *cp_arr, VALUE *memo)
{
  SETBIT(cp_arr, str_cp);
  return 1;
}

static VALUE
method_case_insensitive(VALUE self)
{
  cp_index i;
  cp_byte *new_cps;

  new_cps = alloc_cps();

  FOR_EACH_ACTIVE_CODEPOINT(SETBIT(new_cps, cp));

  for (i = 0; i < CASEFOLD_COUNT; i++)
  {
    casefold_mapping m = unicode_casefold_table[i];

    if (TSTBIT(cps, m.from))
    {
      SETBIT(new_cps, m.to);
    }
    else if (TSTBIT(cps, m.to))
    {
      SETBIT(new_cps, m.from);
    }
  }

  return alloc_cset(RBASIC(self)->klass, new_cps);

  // OnigCaseFoldType flags;
  // rb_encoding *enc;
  //
  // enc = rb_utf8_encoding();
  //
  // ONIGENC_CASE_UPCASE | ONIGENC_CASE_DOWNCASE (not public on ruby < 2.4)
  // flags = (1<<13) | (1<<14);
  //
  // // case_map args: flags, pp, end, to, to_end, enc
  // enc->case_map(flags, (const OnigUChar**)&cp, ?, ?, ?, enc);
}

static inline VALUE
each_sb_cp(VALUE str, str_cp_handler func, cp_byte *cp_arr, VALUE *memo)
{
  long i, len;
  unsigned int str_cp;
  len = RSTRING_LEN(str);

  for (i = 0; i < len; i++)
  {
    str_cp = (RSTRING_PTR(str)[i] & 0xff);
    if (!(*func)(str_cp, cp_arr, memo))
    {
      return Qfalse;
    }
  }

  return Qtrue;
}

static inline VALUE
each_mb_cp(VALUE str, str_cp_handler func, cp_byte *cp_arr, VALUE *memo)
{
  int n;
  unsigned int str_cp;
  const char *ptr, *end;
  rb_encoding *enc;

  str = rb_str_new_frozen(str);
  ptr = RSTRING_PTR(str);
  end = RSTRING_END(str);
  enc = rb_enc_get(str);

  while (ptr < end)
  {
    str_cp = rb_enc_codepoint_len(ptr, end, &n, enc);
    if (!(*func)(str_cp, cp_arr, memo))
    {
      return Qfalse;
    }
    ptr += n;
  }

  return Qtrue;
}

// single_byte_optimizable - copied from string.c
static inline int
single_byte_optimizable(VALUE str)
{
  rb_encoding *enc;
  if (ENC_CODERANGE(str) == ENC_CODERANGE_7BIT)
  {
    return 1;
  }

  enc = rb_enc_get(str);
  if (rb_enc_mbmaxlen(enc) == 1)
  {
    return 1;
  }

  return 0;
}

static inline VALUE
each_cp(VALUE str, str_cp_handler func, cp_byte *cp_arr, VALUE *memo)
{
  if (single_byte_optimizable(str))
  {
    return each_sb_cp(str, func, cp_arr, memo);
  }
  return each_mb_cp(str, func, cp_arr, memo);
}

static inline void
raise_arg_err_unless_string(VALUE val)
{
  if (!RB_TYPE_P(val, T_STRING))
  {
    rb_raise(rb_eArgError, "pass a String");
  }
}

static VALUE
class_method_of(VALUE self, VALUE str)
{
  cp_byte *cp_arr;
  raise_arg_err_unless_string(str);
  cp_arr = alloc_cps();
  each_cp(str, add_str_cp_to_arr, cp_arr, 0);
  return alloc_cset(self, cp_arr);
}

static inline int
count_str_cp(unsigned int str_cp, cp_byte *cp_arr, VALUE *memo)
{
  if (TSTBIT(cp_arr, str_cp))
  {
    *memo += 1;
  }
  return 1;
}

static VALUE
method_count_in(VALUE self, VALUE str)
{
  VALUE count;
  raise_arg_err_unless_string(str);
  count = 0;
  each_cp(str, count_str_cp, fetch_cps(self), &count);
  return INT2NUM(count);
}

static inline int
str_cp_in_arr(unsigned int str_cp, cp_byte *cp_arr, VALUE *memo)
{
  return TSTBIT(cp_arr, str_cp);
}

static VALUE
method_cover_p(VALUE self, VALUE str)
{
  raise_arg_err_unless_string(str);
  return each_cp(str, str_cp_in_arr, fetch_cps(self), 0);
}

static inline int
add_str_cp_to_str_arr(unsigned int str_cp, cp_byte *cp_arr, VALUE *memo)
{
  if (TSTBIT(cp_arr, str_cp))
  {
    rb_ary_push(memo[0], rb_enc_uint_chr((int)str_cp, (rb_encoding *)memo[1]));
  }
  return 1;
}

static VALUE
method_scan(VALUE self, VALUE str)
{
  VALUE memo[2];
  raise_arg_err_unless_string(str);
  memo[0] = rb_ary_new();
  memo[1] = (VALUE)rb_enc_get(str);
  each_cp(str, add_str_cp_to_str_arr, fetch_cps(self), memo);
  return memo[0];
}

static inline int
str_cp_not_in_arr(unsigned int str_cp, cp_byte *cp_arr, VALUE *memo)
{
  return !TSTBIT(cp_arr, str_cp);
}

static VALUE
method_used_by_p(VALUE self, VALUE str)
{
  cp_byte *cps;
  VALUE only_uses_other_cps;
  raise_arg_err_unless_string(str);
  cps = fetch_cps(self);
  only_uses_other_cps = each_cp(str, str_cp_not_in_arr, cps, 0);
  return only_uses_other_cps == Qfalse ? Qtrue : Qfalse;
}

static void
cset_str_buf_cat(VALUE str, const char *ptr, long len)
{
  long total, olen;
  char *sptr;

  RSTRING_GETMEM(str, sptr, olen);
  sptr = RSTRING(str)->as.heap.ptr;
  olen = RSTRING(str)->as.heap.len;
  total = olen + len;
  memcpy(sptr + olen, ptr, len);
  RSTRING(str)->as.heap.len = total;
}

#ifndef TERM_FILL
#define TERM_FILL(ptr, termlen)                     \
  do                                                \
  {                                                 \
    char *const term_fill_ptr = (ptr);              \
    const int term_fill_len = (termlen);            \
    *term_fill_ptr = '\0';                          \
    if (__builtin_expect(!!(term_fill_len > 1), 0)) \
      memset(term_fill_ptr, 0, term_fill_len);      \
  } while (0)
#endif

static void
cset_str_buf_terminate(VALUE str, rb_encoding *enc)
{
  char *ptr;
  long len;

  ptr = RSTRING(str)->as.heap.ptr;
  len = RSTRING(str)->as.heap.len;
  TERM_FILL(ptr + len, rb_enc_mbminlen(enc));
}

static inline VALUE
apply_to_str(VALUE set, VALUE str, int delete, int bang)
{
  cp_byte *cps;
  rb_encoding *str_enc;
  VALUE orig_len, new_str_buf;
  int cp_len;
  unsigned int str_cp;
  const char *ptr, *end;

  raise_arg_err_unless_string(str);

  cps = fetch_cps(set);

  orig_len = RSTRING_LEN(str);
  if (orig_len < 1) // empty string, will never change
  {
    if (bang)
    {
      return Qnil;
    }
    return rb_str_dup(str);
  }

  new_str_buf = rb_str_buf_new(orig_len);
  str_enc = rb_enc_get(str);
  rb_enc_associate(new_str_buf, str_enc);
  rb_str_modify(new_str_buf);
  ENC_CODERANGE_SET(new_str_buf, rb_enc_asciicompat(str_enc) ? ENC_CODERANGE_7BIT : ENC_CODERANGE_VALID);

  ptr = RSTRING_PTR(str);
  end = RSTRING_END(str);

  if (single_byte_optimizable(str))
  {
    while (ptr < end)
    {
      str_cp = *ptr & 0xff;
      if ((!TSTBIT(cps, str_cp)) == delete)
      {
        cset_str_buf_cat(new_str_buf, ptr, 1);
      }
      ptr++;
    }
  }
  else // likely to be multibyte string
  {
    while (ptr < end)
    {
      str_cp = rb_enc_codepoint_len(ptr, end, &cp_len, str_enc);
      if ((!TSTBIT(cps, str_cp)) == delete)
      {
        cset_str_buf_cat(new_str_buf, ptr, cp_len);
      }
      ptr += cp_len;
    }
  }

  cset_str_buf_terminate(new_str_buf, str_enc);

  if (bang)
  {
    if (RSTRING_LEN(new_str_buf) == (long)orig_len) // string unchanged
    {
      return Qnil;
    }
    rb_str_shared_replace(str, new_str_buf);
  }
  else
  {
    RB_OBJ_WRITE(new_str_buf, &(RBASIC(new_str_buf))->klass, rb_obj_class(str));
    // slightly cumbersome approach needed for compatibility with Ruby < 2.3:
    RBASIC(new_str_buf)->flags |= (RBASIC(str)->flags & (FL_TAINT));
    str = new_str_buf;
  }

  return str;
}

static VALUE
method_delete_in(VALUE self, VALUE str)
{
  return apply_to_str(self, str, 1, 0);
}

static VALUE
method_delete_in_bang(VALUE self, VALUE str)
{
  return apply_to_str(self, str, 1, 1);
}

static VALUE
method_keep_in(VALUE self, VALUE str)
{
  return apply_to_str(self, str, 0, 0);
}

static VALUE
method_keep_in_bang(VALUE self, VALUE str)
{
  return apply_to_str(self, str, 0, 1);
}

// ****
// init
// ****

void Init_character_set()
{
  VALUE cs = rb_define_class("CharacterSet", rb_cObject);

  rb_define_alloc_func(cs, method_allocate);

  // `Set` compatibility methods

  rb_define_method(cs, "each", method_each, 0);
  rb_define_method(cs, "to_a", method_to_a, -1);
  rb_define_method(cs, "length", method_length, 0);
  rb_define_method(cs, "size", method_length, 0);
  rb_define_method(cs, "empty?", method_empty_p, 0);
  rb_define_method(cs, "hash", method_hash, 0);
  rb_define_method(cs, "keep_if", method_keep_if, 0);
  rb_define_method(cs, "delete_if", method_delete_if, 0);
  rb_define_method(cs, "clear", method_clear, 0);
  rb_define_method(cs, "intersection", method_intersection, 1);
  rb_define_method(cs, "&", method_intersection, 1);
  rb_define_method(cs, "union", method_union, 1);
  rb_define_method(cs, "+", method_union, 1);
  rb_define_method(cs, "|", method_union, 1);
  rb_define_method(cs, "difference", method_difference, 1);
  rb_define_method(cs, "-", method_difference, 1);
  rb_define_method(cs, "^", method_exclusion, 1);
  rb_define_method(cs, "include?", method_include_p, 1);
  rb_define_method(cs, "member?", method_include_p, 1);
  rb_define_method(cs, "===", method_include_p, 1);
  rb_define_method(cs, "add", method_add, 1);
  rb_define_method(cs, "<<", method_add, 1);
  rb_define_method(cs, "add?", method_add_p, 1);
  rb_define_method(cs, "delete", method_delete, 1);
  rb_define_method(cs, "delete?", method_delete_p, 1);
  rb_define_method(cs, "intersect?", method_intersect_p, 1);
  rb_define_method(cs, "disjoint?", method_disjoint_p, 1);
  rb_define_method(cs, "eql?", method_eql_p, 1);
  rb_define_method(cs, "==", method_eql_p, 1);
  rb_define_method(cs, "merge", method_merge, 1);
  rb_define_method(cs, "initialize_clone", method_initialize_copy, 1);
  rb_define_method(cs, "initialize_dup", method_initialize_copy, 1);
  rb_define_method(cs, "subtract", method_subtract, 1);
  rb_define_method(cs, "subset?", method_subset_p, 1);
  rb_define_method(cs, "<=", method_subset_p, 1);
  rb_define_method(cs, "proper_subset?", method_proper_subset_p, 1);
  rb_define_method(cs, "<", method_proper_subset_p, 1);
  rb_define_method(cs, "superset?", method_superset_p, 1);
  rb_define_method(cs, ">=", method_superset_p, 1);
  rb_define_method(cs, "proper_superset?", method_proper_superset_p, 1);
  rb_define_method(cs, ">", method_proper_superset_p, 1);

  // `CharacterSet`-specific methods

  rb_define_singleton_method(cs, "from_ranges", class_method_from_ranges, -2);
  rb_define_singleton_method(cs, "of", class_method_of, 1);

  rb_define_method(cs, "ranges", method_ranges, 0);
  rb_define_method(cs, "sample", method_sample, -1);
  rb_define_method(cs, "ascii_part", method_ascii_part, 0);
  rb_define_method(cs, "ascii_part?", method_ascii_part_p, 0);
  rb_define_method(cs, "ascii_only?", method_ascii_only_p, 0);
  rb_define_method(cs, "ascii_ratio", method_ascii_ratio, 0);
  rb_define_method(cs, "bmp_part", method_bmp_part, 0);
  rb_define_method(cs, "bmp_part?", method_bmp_part_p, 0);
  rb_define_method(cs, "bmp_only?", method_bmp_only_p, 0);
  rb_define_method(cs, "bmp_ratio", method_bmp_ratio, 0);
  rb_define_method(cs, "astral_part", method_astral_part, 0);
  rb_define_method(cs, "astral_part?", method_astral_part_p, 0);
  rb_define_method(cs, "astral_only?", method_astral_only_p, 0);
  rb_define_method(cs, "astral_ratio", method_astral_ratio, 0);
  rb_define_method(cs, "planes", method_planes, 0);
  rb_define_method(cs, "plane", method_plane, 1);
  rb_define_method(cs, "member_in_plane?", method_member_in_plane_p, 1);
  rb_define_method(cs, "ext_inversion", method_ext_inversion, -1);
  rb_define_method(cs, "case_insensitive", method_case_insensitive, 0);
  rb_define_method(cs, "count_in", method_count_in, 1);
  rb_define_method(cs, "cover?", method_cover_p, 1);
  rb_define_method(cs, "delete_in", method_delete_in, 1);
  rb_define_method(cs, "delete_in!", method_delete_in_bang, 1);
  rb_define_method(cs, "keep_in", method_keep_in, 1);
  rb_define_method(cs, "keep_in!", method_keep_in_bang, 1);
  rb_define_method(cs, "scan", method_scan, 1);
  rb_define_method(cs, "used_by?", method_used_by_p, 1);
}
