#include "ruby.h"
#include "ruby/encoding.h"
#include "unicode_casefold_table.h"

#define UNICODE_PLANE_SIZE 0x10000
#define UNICODE_PLANE_COUNT 17
#define UNICODE_CP_COUNT (UNICODE_PLANE_SIZE * UNICODE_PLANE_COUNT)

// start at ascii size
#define CS_DEFAULT_INITIAL_LEN 128

typedef char cs_ar;
typedef unsigned long cs_cp;

struct cs_data
{
  cs_ar *cps;
  cs_cp len;
};

#define CS_MSIZE(len) (sizeof(cs_ar) * (len / 8))

static inline void
add_memspace_for_another_plane(struct cs_data *data)
{
  data->cps = ruby_xrealloc(data->cps, CS_MSIZE(data->len + UNICODE_PLANE_SIZE));
  memset(data->cps + CS_MSIZE(data->len), 0, CS_MSIZE(UNICODE_PLANE_SIZE));
  data->len += UNICODE_PLANE_SIZE;
}

static inline void
ensure_memsize_fits(struct cs_data *data, cs_cp target_cp)
{
  while (target_cp >= data->len)
  {
    add_memspace_for_another_plane(data);
  }
}

static inline void
set_cp(struct cs_data *data, cs_cp cp)
{
  ensure_memsize_fits(data, cp);
  data->cps[cp >> 3] |= (1 << (cp & 0x07));
}

static inline int
tst_cp(cs_ar *cps, cs_cp len, cs_cp cp)
{
  return ((cp < len) && cps[cp >> 3] & (1 << (cp & 0x07)));
}

static inline void
clr_cp(cs_ar *cps, cs_cp len, cs_cp cp)
{
  if (cp < len)
  {
    cps[cp >> 3] &= ~(1 << (cp & 0x07));
  }
}

static void
cs_free(void *ptr)
{
  struct cs_data *data = ptr;
  ruby_xfree(data->cps);
  ruby_xfree(data);
}

static size_t
cs_memsize(const void *ptr)
{
  const struct cs_data *data = ptr;
  return sizeof(*data) + CS_MSIZE(data->len);
}

static const rb_data_type_t cs_type = {
    .wrap_struct_name = "character_set",
    .function = {
        .dmark = NULL,
        .dfree = cs_free,
        .dsize = cs_memsize,
    },
    .data = NULL,
    .flags = RUBY_TYPED_FREE_IMMEDIATELY,
};

static inline VALUE
cs_alloc_len(VALUE klass, struct cs_data **data_ptr, cs_cp len)
{
  VALUE cs;
  struct cs_data *data;
  cs = TypedData_Make_Struct(klass, struct cs_data, &cs_type, data);
  data->cps = ruby_xmalloc(CS_MSIZE(len));
  memset(data->cps, 0, CS_MSIZE(len));
  data->len = len;

  if (data_ptr)
  {
    *data_ptr = data;
  }

  return cs;
}

static inline VALUE
cs_alloc(VALUE klass, struct cs_data **data_ptr)
{
  return cs_alloc_len(klass, data_ptr, CS_DEFAULT_INITIAL_LEN);
}

static inline struct cs_data *
cs_fetch_data(VALUE cs)
{
  struct cs_data *data;
  TypedData_Get_Struct(cs, struct cs_data, &cs_type, data);
  return data;
}

static inline cs_ar *
cs_fetch_cps(VALUE cs, cs_cp *len_ptr)
{
  struct cs_data *data;
  data = cs_fetch_data(cs);
  *len_ptr = data->len;
  return data->cps;
}

static VALUE
cs_method_allocate(VALUE self)
{
  return cs_alloc(self, 0);
}

#define FOR_EACH_ACTIVE_CODEPOINT(action) \
  do                                      \
  {                                       \
    cs_cp cp, len;                        \
    cs_ar *cps;                           \
    cps = cs_fetch_cps(self, &len);       \
    for (cp = 0; cp < len; cp++)          \
    {                                     \
      if (tst_cp(cps, len, cp))           \
      {                                   \
        action;                           \
      }                                   \
    }                                     \
  } while (0)

// ***************************
// `Set` compatibility methods
// ***************************

static inline cs_cp
cs_active_cp_count(VALUE self)
{
  cs_cp count;
  count = 0;
  FOR_EACH_ACTIVE_CODEPOINT(count++);
  return count;
}

static VALUE
cs_method_length(VALUE self)
{
  return LONG2FIX(cs_active_cp_count(self));
}

static inline VALUE
cs_enumerator_length(VALUE self, VALUE args, VALUE eobj)
{
  return LONG2FIX(cs_active_cp_count(self));
}

static VALUE
cs_method_each(VALUE self)
{
  RETURN_SIZED_ENUMERATOR(self, 0, 0, cs_enumerator_length);
  FOR_EACH_ACTIVE_CODEPOINT(rb_yield(LONG2FIX(cp)));
  return self;
}

// returns an Array of codepoint Integers by default.
// returns an Array of Strings of length 1 if passed `true`.
static VALUE
cs_method_to_a(int argc, VALUE *argv, VALUE self)
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
cs_method_empty_p(VALUE self)
{
  FOR_EACH_ACTIVE_CODEPOINT(return Qfalse);
  return Qtrue;
}

static VALUE
cs_method_hash(VALUE self)
{
  cs_cp cp, len, hash, four_byte_value;
  cs_ar *cps;
  cps = cs_fetch_cps(self, &len);

  hash = 17;
  for (cp = 0; cp < len; cp++)
  {
    if (cp % 32 == 0)
    {
      if (cp != 0)
      {
        hash = hash * 23 + four_byte_value;
      }
      four_byte_value = 0;
    }
    if (tst_cp(cps, len, cp))
    {
      four_byte_value++;
    }
  }

  return LONG2FIX(hash);
}

static inline VALUE
cs_delete_if_block_result(VALUE self, int truthy)
{
  VALUE result;
  rb_need_block();
  rb_check_frozen(self);
  FOR_EACH_ACTIVE_CODEPOINT(
      result = rb_yield(LONG2FIX(cp));
      if ((NIL_P(result) || result == Qfalse) != truthy) clr_cp(cps, len, cp););
  return self;
}

static VALUE
cs_method_delete_if(VALUE self)
{
  RETURN_SIZED_ENUMERATOR(self, 0, 0, cs_enumerator_length);
  return cs_delete_if_block_result(self, 1);
}

static VALUE
cs_method_keep_if(VALUE self)
{
  RETURN_SIZED_ENUMERATOR(self, 0, 0, cs_enumerator_length);
  return cs_delete_if_block_result(self, 0);
}

static VALUE
cs_method_clear(VALUE self)
{
  struct cs_data *data;
  rb_check_frozen(self);
  data = cs_fetch_data(self);
  memset(data->cps, 0, CS_MSIZE(data->len));
  return self;
}

static VALUE
cs_method_min(VALUE self)
{
  FOR_EACH_ACTIVE_CODEPOINT(return LONG2FIX(cp));
  return Qnil;
}

static VALUE
cs_method_max(VALUE self)
{
  cs_cp len;
  long reverse_idx;
  cs_ar *cps;
  cps = cs_fetch_cps(self, &len);
  for (reverse_idx = len; reverse_idx >= 0; reverse_idx--)
  {
    if (tst_cp(cps, len, reverse_idx))
    {
      return LONG2FIX(reverse_idx);
    }
  }
  return Qnil;
}

static VALUE
cs_method_minmax(VALUE self)
{
  VALUE arr;
  arr = rb_ary_new2(2);
  rb_ary_push(arr, cs_method_min(self));
  rb_ary_push(arr, cs_method_max(self));
  return arr;
}

#define RETURN_COMBINED_CS(cs_a, cs_b, comp_op)                  \
  do                                                             \
  {                                                              \
    VALUE new_cs;                                                \
    cs_cp cp, alen, blen;                                        \
    cs_ar *acps, *bcps;                                          \
    struct cs_data *new_data;                                    \
    new_cs = cs_alloc(RBASIC(self)->klass, &new_data);           \
    acps = cs_fetch_cps(cs_a, &alen);                            \
    bcps = cs_fetch_cps(cs_b, &blen);                            \
    for (cp = 0; cp < UNICODE_CP_COUNT; cp++)                    \
    {                                                            \
      if (tst_cp(acps, alen, cp) comp_op tst_cp(bcps, blen, cp)) \
      {                                                          \
        set_cp(new_data, cp);                                    \
      }                                                          \
    }                                                            \
    return new_cs;                                               \
  } while (0)

static VALUE
cs_method_intersection(VALUE self, VALUE other)
{
  RETURN_COMBINED_CS(self, other, &&);
}

static VALUE
cs_method_exclusion(VALUE self, VALUE other)
{
  RETURN_COMBINED_CS(self, other, ^);
}

static VALUE
cs_method_union(VALUE self, VALUE other)
{
  RETURN_COMBINED_CS(self, other, ||);
}

static VALUE
cs_method_difference(VALUE self, VALUE other)
{
  RETURN_COMBINED_CS(self, other, >);
}

static VALUE
cs_method_include_p(VALUE self, VALUE num)
{
  cs_ar *cps;
  cs_cp len;
  cps = cs_fetch_cps(self, &len);
  return (tst_cp(cps, len, FIX2ULONG(num)) ? Qtrue : Qfalse);
}

static inline VALUE
cs_toggle_codepoint(VALUE cs, VALUE cp_num, int on, int return_nil_if_noop)
{
  cs_cp cp, len;
  cs_ar *cps;
  struct cs_data *data;
  rb_check_frozen(cs);
  data = cs_fetch_data(cs);
  cps = data->cps;
  len = data->len;
  cp = FIX2ULONG(cp_num);
  if (return_nil_if_noop && (!tst_cp(cps, len, cp) == !on))
  {
    return Qnil;
  }
  else
  {
    if (on)
    {
      set_cp(data, cp);
    }
    else
    {
      clr_cp(cps, len, cp);
    }
    return cs;
  }
}

static VALUE
cs_method_add(VALUE self, VALUE cp_num)
{
  return cs_toggle_codepoint(self, cp_num, 1, 0);
}

static VALUE
cs_method_add_p(VALUE self, VALUE cp_num)
{
  return cs_toggle_codepoint(self, cp_num, 1, 1);
}

static VALUE
cs_method_delete(VALUE self, VALUE cp_num)
{
  return cs_toggle_codepoint(self, cp_num, 0, 0);
}

static VALUE
cs_method_delete_p(VALUE self, VALUE cp_num)
{
  return cs_toggle_codepoint(self, cp_num, 0, 1);
}

static VALUE
cs_method_intersect_p(VALUE self, VALUE other)
{
  cs_cp cp, alen, blen;
  cs_ar *acps, *bcps;
  acps = cs_fetch_cps(self, &alen);
  bcps = cs_fetch_cps(other, &blen);
  for (cp = 0; cp < UNICODE_CP_COUNT; cp++)
  {
    if (tst_cp(acps, alen, cp) && tst_cp(bcps, blen, cp))
    {
      return Qtrue;
    }
  }
  return Qfalse;
}

static VALUE
cs_method_disjoint_p(VALUE self, VALUE other)
{
  return cs_method_intersect_p(self, other) ? Qfalse : Qtrue;
}

static inline int
cs_check_type(VALUE obj)
{
  return rb_typeddata_is_kind_of(obj, &cs_type);
}

static VALUE
cs_cps_eql(VALUE cs_a, VALUE cs_b)
{
  cs_cp cp, alen, blen;
  cs_ar *acps, *bcps;
  acps = cs_fetch_cps(cs_a, &alen);
  bcps = cs_fetch_cps(cs_b, &blen);
  for (cp = 0; cp < UNICODE_CP_COUNT; cp++)
  {
    if (tst_cp(acps, alen, cp) != tst_cp(bcps, blen, cp))
    {
      return Qfalse;
    }
  }
  return Qtrue;
}

static VALUE
cs_method_eql_p(VALUE self, VALUE other)
{
  if (!cs_check_type(other))
  {
    return Qfalse;
  }
  if (self == other) // same object_id
  {
    return Qtrue;
  }
  return cs_cps_eql(self, other);
}

static inline VALUE
cs_merge_cs(VALUE recipient, VALUE source)
{
  cs_cp cp, source_len;
  struct cs_data *data;
  cs_ar *source_cps;
  data = cs_fetch_data(recipient);
  source_cps = cs_fetch_cps(source, &source_len);
  for (cp = 0; cp < UNICODE_CP_COUNT; cp++)
  {
    if (tst_cp(source_cps, source_len, cp))
    {
      set_cp(data, cp);
    }
  }
  return recipient;
}

static inline cs_cp
cs_checked_cp(VALUE object_id)
{
  if (FIXNUM_P(object_id) && object_id > 0 && object_id < 0x220001)
  {
    return FIX2ULONG(object_id);
  }
  rb_raise(rb_eArgError, "CharacterSet members must be between 0 and 0x10FFFF");
}

static inline VALUE
cs_merge_rb_range(VALUE self, VALUE rb_range)
{
  VALUE from_id, upto_id;
  cs_cp from_cp, upto_cp, cont_len, rem;
  int excl;
  struct cs_data *data;
  data = cs_fetch_data(self);

  if (!RTEST(rb_range_values(rb_range, &from_id, &upto_id, &excl)))
  {
    rb_raise(rb_eArgError, "pass a Range");
  }
  if (excl)
  {
    upto_id -= 2;
  }

  from_cp = cs_checked_cp(from_id);
  upto_cp = cs_checked_cp(upto_id);

  if (upto_cp > from_cp && (upto_cp - from_cp > 6))
  {
    // set bits in preceding partially toggled bytes individually
    for (/* */; (from_cp <= upto_cp) && (from_cp % 8); from_cp++)
    {
      set_cp(data, from_cp);
    }
    // memset contiguous bits directly
    cont_len = upto_cp - from_cp + 1;
    rem = cont_len % 8;
    ensure_memsize_fits(data, upto_cp);
    memset(data->cps + CS_MSIZE(from_cp), 0xFF, CS_MSIZE(cont_len - rem) / 8);
    from_cp = upto_cp - rem + 1;
  }

  // set bits in partially toggled bytes individually
  for (/* */; from_cp <= upto_cp; from_cp++)
  {
    set_cp(data, from_cp);
  }

  return self;
}

static inline VALUE
cs_merge_rb_array(VALUE self, VALUE rb_array)
{
  VALUE el, array_length, i;
  struct cs_data *data;
  Check_Type(rb_array, T_ARRAY);
  data = cs_fetch_data(self);
  array_length = RARRAY_LEN(rb_array);
  for (i = 0; i < array_length; i++)
  {
    el = RARRAY_AREF(rb_array, i);
    set_cp(data, cs_checked_cp(el));
  }
  return self;
}

static VALUE
cs_method_merge(VALUE self, VALUE other)
{
  rb_check_frozen(self);
  if (cs_check_type(other))
  {
    return cs_merge_cs(self, other);
  }
  else if (TYPE(other) == T_ARRAY)
  {
    return cs_merge_rb_array(self, other);
  }
  return cs_merge_rb_range(self, other);
}

static VALUE
cs_method_initialize_copy(VALUE self, VALUE orig)
{
  cs_merge_cs(self, orig);
  return self;
}

static VALUE
cs_method_subtract(VALUE self, VALUE other)
{
  cs_cp cp, len, other_len;
  cs_ar *cps, *other_cps;
  rb_check_frozen(self);
  cps = cs_fetch_cps(self, &len);
  other_cps = cs_fetch_cps(other, &other_len);
  for (cp = 0; cp < UNICODE_CP_COUNT; cp++)
  {
    if (tst_cp(other_cps, other_len, cp))
    {
      clr_cp(cps, len, cp);
    }
  }
  return self;
}

static inline int
cs_a_subset_of_b(VALUE cs_a, VALUE cs_b, int *is_proper_ptr)
{
  cs_ar *a, *b;
  cs_cp cp, alen, blen, count_a, count_b;

  if (!cs_check_type(cs_a) || !cs_check_type(cs_b))
  {
    rb_raise(rb_eArgError, "pass a CharacterSet");
  }

  a = cs_fetch_cps(cs_a, &alen);
  b = cs_fetch_cps(cs_b, &blen);

  count_a = 0;
  count_b = 0;

  for (cp = 0; cp < UNICODE_CP_COUNT; cp++)
  {
    if (tst_cp(a, alen, cp))
    {
      if (!tst_cp(b, blen, cp))
      {
        return 0;
      }
      count_a++;
      count_b++;
    }
    else if (tst_cp(b, blen, cp))
    {
      count_b++;
    }
  }

  if (is_proper_ptr)
  {
    *is_proper_ptr = count_b > count_a;
  }

  return 1;
}

static VALUE
cs_method_subset_p(VALUE self, VALUE other)
{
  return cs_a_subset_of_b(self, other, NULL) ? Qtrue : Qfalse;
}

static VALUE
cs_method_proper_subset_p(VALUE self, VALUE other)
{
  int is_subset, is_proper;
  is_subset = cs_a_subset_of_b(self, other, &is_proper);
  return (is_subset && is_proper) ? Qtrue : Qfalse;
}

static VALUE
cs_method_superset_p(VALUE self, VALUE other)
{
  return cs_a_subset_of_b(other, self, NULL) ? Qtrue : Qfalse;
}

static VALUE
cs_method_proper_superset_p(VALUE self, VALUE other)
{
  int is_superset, is_proper;
  is_superset = cs_a_subset_of_b(other, self, &is_proper);
  return (is_superset && is_proper) ? Qtrue : Qfalse;
}

// *******************************
// `CharacterSet`-specific methods
// *******************************

static VALUE
cs_class_method_from_ranges(VALUE self, VALUE ranges)
{
  VALUE new_cs, range_count, i;
  new_cs = rb_class_new_instance(0, 0, self);
  range_count = RARRAY_LEN(ranges);
  for (i = 0; i < range_count; i++)
  {
    cs_merge_rb_range(new_cs, RARRAY_AREF(ranges, i));
  }
  return new_cs;
}

static VALUE
cs_method_ranges(VALUE self)
{
  VALUE ranges, cp_num, previous_cp_num, current_start, current_end;

  ranges = rb_ary_new();
  previous_cp_num = 0;
  current_start = 0;
  current_end = 0;

  FOR_EACH_ACTIVE_CODEPOINT(
      cp_num = LONG2FIX(cp);

      if (!previous_cp_num) {
        current_start = cp_num;
      } else if (previous_cp_num + 2 != cp_num) {
        // gap found, finalize previous range
        rb_ary_push(ranges, rb_range_new(current_start, current_end, 0));
        current_start = cp_num;
      } current_end = cp_num;
      previous_cp_num = cp_num;);

  // add final range
  if (current_start)
  {
    rb_ary_push(ranges, rb_range_new(current_start, current_end, 0));
  }

  return ranges;
}

static VALUE
cs_method_sample(int argc, VALUE *argv, VALUE self)
{
  VALUE array, to_a_args[1] = {Qtrue};
  rb_check_arity(argc, 0, 1);
  array = cs_method_to_a(1, to_a_args, self);
  return rb_funcall(array, rb_intern("sample"), argc, argc ? argv[0] : 0);
}

static inline VALUE
cs_from_section(VALUE set, cs_cp from, cs_cp upto)
{
  VALUE new_cs;
  cs_ar *cps;
  cs_cp cp, len;
  struct cs_data *new_data;
  new_cs = cs_alloc(RBASIC(set)->klass, &new_data);
  cps = cs_fetch_cps(set, &len);
  for (cp = from; cp <= upto; cp++)
  {
    if (tst_cp(cps, len, cp))
    {
      set_cp(new_data, cp);
    }
  }
  return new_cs;
}

static VALUE
cs_method_ext_section(VALUE self, VALUE from, VALUE upto)
{
  return cs_from_section(self, FIX2ULONG(from), FIX2ULONG(upto));
}

static inline cs_cp
cs_active_cp_count_in_section(VALUE set, cs_cp from, cs_cp upto)
{
  cs_ar *cps;
  cs_cp cp, count, len;
  cps = cs_fetch_cps(set, &len);
  for (count = 0, cp = from; cp <= upto; cp++)
  {
    if (tst_cp(cps, len, cp))
    {
      count++;
    }
  }
  return count;
}

static VALUE
cs_method_ext_count_in_section(VALUE self, VALUE from, VALUE upto)
{
  cs_cp count;
  count = cs_active_cp_count_in_section(self, FIX2ULONG(from), FIX2ULONG(upto));
  return LONG2FIX(count);
}

static inline VALUE
cs_has_cp_in_section(cs_ar *cps, cs_cp len, cs_cp from, cs_cp upto)
{
  cs_cp cp;
  for (cp = from; cp <= upto; cp++)
  {
    if (tst_cp(cps, len, cp))
    {
      return Qtrue;
    }
  }
  return Qfalse;
}

static VALUE
cs_method_ext_section_p(VALUE self, VALUE from, VALUE upto)
{
  cs_ar *cps;
  cs_cp len;
  cps = cs_fetch_cps(self, &len);
  return cs_has_cp_in_section(cps, len, FIX2ULONG(from), FIX2ULONG(upto));
}

static inline VALUE
cs_ratio_of_section(VALUE set, cs_cp from, cs_cp upto)
{
  double section_count, total_count;
  section_count = (double)cs_active_cp_count_in_section(set, from, upto);
  total_count = (double)cs_active_cp_count(set);
  return DBL2NUM(section_count / total_count);
}

static VALUE
cs_method_ext_section_ratio(VALUE self, VALUE from, VALUE upto)
{
  return cs_ratio_of_section(self, FIX2ULONG(from), FIX2ULONG(upto));
}

#define MAX_CP 0x10FFFF
#define MAX_ASCII_CP 0x7F
#define MAX_BMP_CP 0xFFFF
#define MIN_ASTRAL_CP 0x10000

static inline VALUE
cs_has_cp_in_plane(cs_ar *cps, cs_cp len, unsigned int plane)
{
  cs_cp plane_beg, plane_end;
  plane_beg = plane * UNICODE_PLANE_SIZE;
  plane_end = (plane + 1) * MAX_BMP_CP;
  return cs_has_cp_in_section(cps, len, plane_beg, plane_end);
}

static VALUE
cs_method_planes(VALUE self)
{
  cs_ar *cps;
  cs_cp len;
  unsigned int i;
  VALUE planes;
  cps = cs_fetch_cps(self, &len);
  planes = rb_ary_new();
  for (i = 0; i < UNICODE_PLANE_COUNT; i++)
  {
    if (cs_has_cp_in_plane(cps, len, i))
    {
      rb_ary_push(planes, INT2FIX(i));
    }
  }
  return planes;
}

static inline int
cs_valid_plane_num(VALUE num)
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
cs_method_plane(VALUE self, VALUE plane_num)
{
  cs_cp plane, plane_beg, plane_end;
  plane = cs_valid_plane_num(plane_num);
  plane_beg = plane * UNICODE_PLANE_SIZE;
  plane_end = (plane + 1) * MAX_BMP_CP;
  return cs_from_section(self, plane_beg, plane_end);
}

static VALUE
cs_method_member_in_plane_p(VALUE self, VALUE plane_num)
{
  cs_ar *cps;
  cs_cp len;
  unsigned int plane;
  plane = cs_valid_plane_num(plane_num);
  cps = cs_fetch_cps(self, &len);
  return cs_has_cp_in_plane(cps, len, plane);
}

#define NON_SURROGATE(cp) (cp > 0xDFFF || cp < 0xD800)

static VALUE
cs_method_ext_inversion(int argc, VALUE *argv, VALUE self)
{
  int inc_surr;
  cs_cp upto, cp, len;
  cs_ar *cps;
  VALUE new_cs;
  struct cs_data *new_data;

  rb_check_arity(argc, 0, 2);

  cps = cs_fetch_cps(self, &len);
  inc_surr = argc && argv[0] == Qtrue;
  new_cs = cs_alloc(RBASIC(self)->klass, &new_data);
  upto = argc > 1 && FIXNUM_P(argv[1]) ? FIX2ULONG(argv[1]) : UNICODE_CP_COUNT;

  for (cp = 0; cp < UNICODE_CP_COUNT; cp++)
  {
    if (cp <= upto && !tst_cp(cps, len, cp) && (inc_surr || NON_SURROGATE(cp)))
    {
      set_cp(new_data, cp);
    }
  }

  return new_cs;
}

typedef int (*str_cp_handler)(unsigned int, cs_ar *, cs_cp len, struct cs_data *data, VALUE *memo);

static inline int
add_str_cp_to_arr(unsigned int str_cp, cs_ar *cp_arr, cs_cp len, struct cs_data *data, VALUE *memo)
{
  set_cp(data, str_cp);
  return 1;
}

static VALUE
cs_method_case_insensitive(VALUE self)
{
  cs_cp i, len;
  cs_ar *cps;
  VALUE new_cs;
  struct cs_data *new_data;

  cps = cs_fetch_cps(self, &len);
  new_cs = cs_alloc(RBASIC(self)->klass, &new_data);
  cs_merge_cs(new_cs, self);

  for (i = 0; i < CASEFOLD_COUNT; i++)
  {
    casefold_mapping m = unicode_casefold_table[i];

    if (tst_cp(cps, len, m.from))
    {
      set_cp(new_data, m.to);
    }
    else if (tst_cp(cps, len, m.to))
    {
      set_cp(new_data, m.from);
    }
  }

  return new_cs;

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
each_sb_cp(VALUE str, str_cp_handler func, cs_ar *cp_arr, cs_cp len, struct cs_data *data, VALUE *memo)
{
  long i, str_len;
  unsigned int str_cp;
  str_len = RSTRING_LEN(str);

  for (i = 0; i < str_len; i++)
  {
    str_cp = (RSTRING_PTR(str)[i] & 0xff);
    if (!(*func)(str_cp, cp_arr, len, data, memo))
    {
      return Qfalse;
    }
  }

  return Qtrue;
}

static inline VALUE
each_mb_cp(VALUE str, str_cp_handler func, cs_ar *cp_arr, cs_cp len, struct cs_data *data, VALUE *memo)
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
    if (!(*func)(str_cp, cp_arr, len, data, memo))
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
each_cp(VALUE str, str_cp_handler func, cs_ar *cp_arr, cs_cp len, struct cs_data *data, VALUE *memo)
{
  if (single_byte_optimizable(str))
  {
    return each_sb_cp(str, func, cp_arr, len, data, memo);
  }
  return each_mb_cp(str, func, cp_arr, len, data, memo);
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
cs_class_method_of(VALUE self, VALUE str)
{
  VALUE new_cs;
  struct cs_data *new_data;
  new_cs = cs_alloc(self, &new_data);
  raise_arg_err_unless_string(str);
  each_cp(str, add_str_cp_to_arr, 0, 0, new_data, 0);
  return new_cs;
}

static inline int
count_str_cp(unsigned int str_cp, cs_ar *cp_arr, cs_cp len, struct cs_data *data, VALUE *memo)
{
  if (tst_cp(cp_arr, len, str_cp))
  {
    *memo += 1;
  }
  return 1;
}

static VALUE
cs_method_count_in(VALUE self, VALUE str)
{
  VALUE count;
  struct cs_data *data;
  raise_arg_err_unless_string(str);
  data = cs_fetch_data(self);
  count = 0;
  each_cp(str, count_str_cp, data->cps, data->len, data, &count);
  return INT2NUM(count);
}

static inline int
str_cp_in_arr(unsigned int str_cp, cs_ar *cp_arr, cs_cp len, struct cs_data *data, VALUE *memo)
{
  return tst_cp(cp_arr, len, str_cp);
}

static VALUE
cs_method_cover_p(VALUE self, VALUE str)
{
  struct cs_data *data;
  raise_arg_err_unless_string(str);
  data = cs_fetch_data(self);
  return each_cp(str, str_cp_in_arr, data->cps, data->len, data, 0);
}

static inline int
add_str_cp_to_str_arr(unsigned int str_cp, cs_ar *cp_arr, cs_cp len, struct cs_data *data, VALUE *memo)
{
  if (tst_cp(cp_arr, len, str_cp))
  {
    rb_ary_push(memo[0], rb_enc_uint_chr((int)str_cp, (rb_encoding *)memo[1]));
  }
  return 1;
}

static VALUE
cs_method_scan(VALUE self, VALUE str)
{
  VALUE memo[2];
  struct cs_data *data;
  raise_arg_err_unless_string(str);
  data = cs_fetch_data(self);
  memo[0] = rb_ary_new();
  memo[1] = (VALUE)rb_enc_get(str);
  each_cp(str, add_str_cp_to_str_arr, data->cps, data->len, data, memo);
  return memo[0];
}

static inline int
str_cp_not_in_arr(unsigned int str_cp, cs_ar *cp_arr, cs_cp len, struct cs_data *data, VALUE *memo)
{
  return !tst_cp(cp_arr, len, str_cp);
}

static VALUE
cs_method_used_by_p(VALUE self, VALUE str)
{
  VALUE only_uses_other_cps;
  struct cs_data *data;
  raise_arg_err_unless_string(str);
  data = cs_fetch_data(self);
  only_uses_other_cps = each_cp(str, str_cp_not_in_arr, data->cps, data->len, data, 0);
  return only_uses_other_cps == Qfalse ? Qtrue : Qfalse;
}

static void
cs_str_buf_cat(VALUE str, const char *ptr, long len)
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
cs_str_buf_terminate(VALUE str, rb_encoding *enc)
{
  char *ptr;
  long len;

  ptr = RSTRING(str)->as.heap.ptr;
  len = RSTRING(str)->as.heap.len;
  TERM_FILL(ptr + len, rb_enc_mbminlen(enc));
}

static inline VALUE
cs_apply_to_str(VALUE set, VALUE str, int delete, int bang)
{
  cs_ar *cps;
  cs_cp len;
  rb_encoding *str_enc;
  VALUE orig_len, new_str_buf;
  int cp_len;
  unsigned int str_cp;
  const char *ptr, *end;

  raise_arg_err_unless_string(str);

  cps = cs_fetch_cps(set, &len);

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
      if ((!tst_cp(cps, len, str_cp)) == delete)
      {
        cs_str_buf_cat(new_str_buf, ptr, 1);
      }
      ptr++;
    }
  }
  else // likely to be multibyte string
  {
    while (ptr < end)
    {
      str_cp = rb_enc_codepoint_len(ptr, end, &cp_len, str_enc);
      if ((!tst_cp(cps, len, str_cp)) == delete)
      {
        cs_str_buf_cat(new_str_buf, ptr, cp_len);
      }
      ptr += cp_len;
    }
  }

  cs_str_buf_terminate(new_str_buf, str_enc);

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
cs_method_delete_in(VALUE self, VALUE str)
{
  return cs_apply_to_str(self, str, 1, 0);
}

static VALUE
cs_method_delete_in_bang(VALUE self, VALUE str)
{
  return cs_apply_to_str(self, str, 1, 1);
}

static VALUE
cs_method_keep_in(VALUE self, VALUE str)
{
  return cs_apply_to_str(self, str, 0, 0);
}

static VALUE
cs_method_keep_in_bang(VALUE self, VALUE str)
{
  return cs_apply_to_str(self, str, 0, 1);
}

static VALUE
cs_method_allocated_length(VALUE self)
{
  return LONG2FIX(cs_fetch_data(self)->len);
}

// ****
// init
// ****

void Init_character_set()
{
  VALUE cs = rb_define_class("CharacterSet", rb_cObject);

  rb_define_alloc_func(cs, cs_method_allocate);

  // `Set` compatibility methods

  rb_define_method(cs, "each", cs_method_each, 0);
  rb_define_method(cs, "to_a", cs_method_to_a, -1);
  rb_define_method(cs, "length", cs_method_length, 0);
  rb_define_method(cs, "size", cs_method_length, 0);
  rb_define_method(cs, "empty?", cs_method_empty_p, 0);
  rb_define_method(cs, "hash", cs_method_hash, 0);
  rb_define_method(cs, "keep_if", cs_method_keep_if, 0);
  rb_define_method(cs, "delete_if", cs_method_delete_if, 0);
  rb_define_method(cs, "clear", cs_method_clear, 0);
  rb_define_method(cs, "min", cs_method_min, 0);
  rb_define_method(cs, "max", cs_method_max, 0);
  rb_define_method(cs, "minmax", cs_method_minmax, 0);
  rb_define_method(cs, "intersection", cs_method_intersection, 1);
  rb_define_method(cs, "&", cs_method_intersection, 1);
  rb_define_method(cs, "union", cs_method_union, 1);
  rb_define_method(cs, "+", cs_method_union, 1);
  rb_define_method(cs, "|", cs_method_union, 1);
  rb_define_method(cs, "difference", cs_method_difference, 1);
  rb_define_method(cs, "-", cs_method_difference, 1);
  rb_define_method(cs, "^", cs_method_exclusion, 1);
  rb_define_method(cs, "include?", cs_method_include_p, 1);
  rb_define_method(cs, "member?", cs_method_include_p, 1);
  rb_define_method(cs, "===", cs_method_include_p, 1);
  rb_define_method(cs, "add", cs_method_add, 1);
  rb_define_method(cs, "<<", cs_method_add, 1);
  rb_define_method(cs, "add?", cs_method_add_p, 1);
  rb_define_method(cs, "delete", cs_method_delete, 1);
  rb_define_method(cs, "delete?", cs_method_delete_p, 1);
  rb_define_method(cs, "intersect?", cs_method_intersect_p, 1);
  rb_define_method(cs, "disjoint?", cs_method_disjoint_p, 1);
  rb_define_method(cs, "eql?", cs_method_eql_p, 1);
  rb_define_method(cs, "==", cs_method_eql_p, 1);
  rb_define_method(cs, "merge", cs_method_merge, 1);
  rb_define_method(cs, "initialize_clone", cs_method_initialize_copy, 1);
  rb_define_method(cs, "initialize_dup", cs_method_initialize_copy, 1);
  rb_define_method(cs, "subtract", cs_method_subtract, 1);
  rb_define_method(cs, "subset?", cs_method_subset_p, 1);
  rb_define_method(cs, "<=", cs_method_subset_p, 1);
  rb_define_method(cs, "proper_subset?", cs_method_proper_subset_p, 1);
  rb_define_method(cs, "<", cs_method_proper_subset_p, 1);
  rb_define_method(cs, "superset?", cs_method_superset_p, 1);
  rb_define_method(cs, ">=", cs_method_superset_p, 1);
  rb_define_method(cs, "proper_superset?", cs_method_proper_superset_p, 1);
  rb_define_method(cs, ">", cs_method_proper_superset_p, 1);

  // `CharacterSet`-specific methods

  rb_define_singleton_method(cs, "from_ranges", cs_class_method_from_ranges, -2);
  rb_define_singleton_method(cs, "of", cs_class_method_of, 1);

  rb_define_method(cs, "ranges", cs_method_ranges, 0);
  rb_define_method(cs, "sample", cs_method_sample, -1);
  rb_define_method(cs, "ext_section", cs_method_ext_section, 2);
  rb_define_method(cs, "ext_count_in_section", cs_method_ext_count_in_section, 2);
  rb_define_method(cs, "ext_section?", cs_method_ext_section_p, 2);
  rb_define_method(cs, "ext_section_ratio", cs_method_ext_section_ratio, 2);
  rb_define_method(cs, "planes", cs_method_planes, 0);
  rb_define_method(cs, "plane", cs_method_plane, 1);
  rb_define_method(cs, "member_in_plane?", cs_method_member_in_plane_p, 1);
  rb_define_method(cs, "ext_inversion", cs_method_ext_inversion, -1);
  rb_define_method(cs, "case_insensitive", cs_method_case_insensitive, 0);
  rb_define_method(cs, "count_in", cs_method_count_in, 1);
  rb_define_method(cs, "cover?", cs_method_cover_p, 1);
  rb_define_method(cs, "delete_in", cs_method_delete_in, 1);
  rb_define_method(cs, "delete_in!", cs_method_delete_in_bang, 1);
  rb_define_method(cs, "keep_in", cs_method_keep_in, 1);
  rb_define_method(cs, "keep_in!", cs_method_keep_in_bang, 1);
  rb_define_method(cs, "scan", cs_method_scan, 1);
  rb_define_method(cs, "used_by?", cs_method_used_by_p, 1);
  rb_define_method(cs, "allocated_length", cs_method_allocated_length, 0);
}
