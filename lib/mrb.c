/* -*- c-basic-offset: 2 -*- */
/*
  Copyright(C) 2013 Brazil

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License version 2.1 as published by the Free Software Foundation.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/

#include "mrb.h"
#include "ctx_impl.h"

#ifdef GRN_WITH_MRUBY
# include <mruby/proc.h>
# include <mruby/compile.h>
# include <mruby/class.h>
# include <mruby/variable.h>
# include <mruby/data.h>
# include <mruby/array.h>
#endif

#ifdef GRN_WITH_MRUBY
static mrb_value
grn_mrb_scan_info_build(mrb_state *mrb, mrb_value self)
{
  mrb_value expr, var, n;
  mrb_int op, size;
  mrb_get_args(mrb, "oooii", &expr, &var, &n, &op, &size);
  if (scan_info_build_with_mrb(mrb->ud, DATA_PTR(self), DATA_PTR(expr),
                               DATA_PTR(var), mrb_voidp(n), op, size)) {
    return mrb_true_value();
  }
  return mrb_false_value();
}

static struct mrb_data_type mrb_scaninfov_type = { "ScaninfoVector", NULL };
static struct mrb_data_type mrb_expr_type = { "Expr", NULL };
static struct mrb_data_type mrb_obj_type = { "Obj", NULL };

static void
grn_mrb_init_expr(grn_ctx *ctx)
{
  mrb_state *mrb = ctx->impl->mrb;
  struct RClass *klass;
  klass = mrb_define_class(mrb, "ScaninfoVector", mrb->object_class);
  MRB_SET_INSTANCE_TT(klass, MRB_TT_DATA);
  mrb_iv_set(mrb, mrb_obj_value(klass), mrb_intern(mrb, "type"), mrb_voidp_value(&mrb_scaninfov_type));
  mrb_define_method(mrb, klass, "build", grn_mrb_scan_info_build, ARGS_REQ(5));
  klass = mrb_define_class(mrb, "Expr", mrb->object_class);
  MRB_SET_INSTANCE_TT(klass, MRB_TT_DATA);
  mrb_iv_set(mrb, mrb_obj_value(klass), mrb_intern(mrb, "type"), mrb_voidp_value(&mrb_expr_type));
  klass = mrb_define_class(mrb, "Obj", mrb->object_class);
  MRB_SET_INSTANCE_TT(klass, MRB_TT_DATA);
  mrb_iv_set(mrb, mrb_obj_value(klass), mrb_intern(mrb, "type"), mrb_voidp_value(&mrb_obj_type));
}

void
grn_ctx_impl_mrb_init(grn_ctx *ctx)
{
  const char *grn_mruby_enabled;
  grn_mruby_enabled = getenv("GRN_MRUBY_ENABLED");
  if (grn_mruby_enabled && strcmp(grn_mruby_enabled, "no") == 0) {
    ctx->impl->mrb = NULL;
  } else {
    ctx->impl->mrb = mrb_open();
    ctx->impl->mrb->ud = ctx;
    grn_mrb_init_expr(ctx);
  }
}

void
grn_ctx_impl_mrb_fin(grn_ctx *ctx)
{
  if (ctx->impl->mrb) {
    mrb_close(ctx->impl->mrb);
    ctx->impl->mrb = NULL;
  }
}

mrb_value
grn_mrb_eval(grn_ctx *ctx, const char *script, int script_length)
{
  mrb_state *mrb = ctx->impl->mrb;
  int n;
  mrb_value result;
  struct mrb_parser_state *parser;

  if (!mrb) {
    return mrb_nil_value();
  }

  if (script_length < 0) {
    script_length = strlen(script);
  }
  parser = mrb_parse_nstring(mrb, script, script_length, NULL);
  n = mrb_generate_code(mrb, parser);
  result = mrb_run(mrb,
                   mrb_proc_new(mrb, mrb->irep[n]),
                   mrb_top_self(mrb));
  mrb_parser_free(parser);

  return result;
}

int
grn_mrb_send(grn_ctx *ctx, void *buf, const char *mname)
{
  int ret;
  mrb_state *mrb = ctx->impl->mrb;
  mrb_value ary, self, *args;
  ary = mrb_obj_value(buf);
  self = RARRAY_PTR(ary)[1];
  args = RARRAY_PTR(ary) + 2;
  ret = mrb_test(mrb_funcall_argv(mrb, self, mrb_intern(mrb, mname), RARRAY_LEN(ary) - 2, args));
  mrb_gc_arena_restore(mrb, mrb_fixnum(RARRAY_PTR(ary)[0]));
  return ret;
}

grn_rc
grn_mrb_to_grn(grn_ctx *ctx, mrb_value mrb_object, grn_obj *grn_object)
{
  grn_rc rc = GRN_SUCCESS;

  switch (mrb_type(mrb_object)) {
  case MRB_TT_FIXNUM :
    grn_obj_reinit(ctx, grn_object, GRN_DB_INT32, 0);
    GRN_INT32_SET(ctx, grn_object, mrb_fixnum(mrb_object));
    break;
  default :
    rc = GRN_INVALID_ARGUMENT;
    break;
  }

  return rc;
}

void *
grn_mrb_get_argbuf(grn_ctx *ctx)
{
  mrb_state *mrb = ctx->impl->mrb;
  int ai = mrb_gc_arena_save(mrb);
  mrb_value ary = mrb_ary_new(mrb);
  mrb_ary_push(mrb, ary, mrb_fixnum_value(ai));
 return mrb_ary_ptr(ary);
}

void
grn_mrb_push_ptr(grn_ctx *ctx, void *buf, void *ptr, const char *cname)
{
  mrb_state *mrb = ctx->impl->mrb;
  mrb_value obj;
  if (cname) {
    struct RClass *klass = mrb_class_get(mrb, cname);
    mrb_value type = mrb_iv_get(mrb, mrb_obj_value(klass), mrb_intern(mrb, "type"));
    obj = mrb_obj_value(Data_Wrap_Struct(mrb, klass, mrb_voidp(type), ptr));
  } else {
    obj = mrb_voidp_value(ptr);
  }
  mrb_ary_push(mrb, mrb_obj_value(buf), obj);
}

void
grn_mrb_push_int(grn_ctx *ctx, void *buf, int i)
{
  mrb_state *mrb = ctx->impl->mrb;
  mrb_value obj;
  obj = mrb_fixnum_value(i);
  mrb_ary_push(mrb, mrb_obj_value(buf), obj);
}
#else
void
grn_ctx_impl_mrb_init(grn_ctx *ctx)
{
}

void
grn_ctx_impl_mrb_fin(grn_ctx *ctx)
{
}
#endif
