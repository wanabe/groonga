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
# include <mruby/string.h>
#endif

#ifdef GRN_WITH_MRUBY
mrb_value
grn_mrb_eval(grn_ctx *ctx, const char *script, int script_length)
{
  mrb_state *mrb = ctx->impl->mrb.state;
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

grn_rc
grn_mrb_send(grn_ctx *ctx, grn_obj *grn_recv, const char *name, int argc,
             grn_obj *grn_argv, grn_obj *grn_ret)
{
  int ai;
  grn_rc stat;
  mrb_state *mrb = ctx->impl->mrb.state;
  ai = mrb_gc_arena_save(mrb);
  /* TODO: convert groonga <=> mruby object */
  mrb_funcall(mrb, mrb_obj_value(ctx->impl->mrb.module), name, 2,
              mrb_cptr_value(mrb, grn_recv), mrb_cptr_value(mrb, grn_argv));
  if (ctx->rc) {
    stat = ctx->rc;
    mrb->exc = NULL;
  } else if (mrb->exc) {
    mrb_value msg = mrb_inspect(mrb, mrb_obj_value(mrb->exc));
    ERR(GRN_UNKNOWN_ERROR, "mruby error - %s", RSTRING_PTR(msg));
    stat = GRN_UNKNOWN_ERROR;
    mrb->exc = NULL;
  } else {
    stat = GRN_SUCCESS;
  }
  mrb_gc_arena_restore(mrb, ai);
  return stat;
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
  case MRB_TT_STRING :
    grn_obj_reinit(ctx, grn_object, GRN_DB_TEXT, 0);
    GRN_TEXT_SET(ctx, grn_object,
                 RSTRING_PTR(mrb_object),
                 RSTRING_LEN(mrb_object));
    break;
  default :
    rc = GRN_INVALID_ARGUMENT;
    break;
  }

  return rc;
}
#endif
