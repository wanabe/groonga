/* -*- c-basic-offset: 2 -*- */

#include <groonga.h>
#include <groonga/plugin.h>

static grn_obj *
mruby_init(grn_ctx *ctx, int nargs, grn_obj **args, grn_user_data *user_data)
{
  user_data->ptr = mrb_open();
  return NULL;
}

static grn_obj *
mruby_next(grn_ctx *ctx, int nargs, grn_obj **args, grn_user_data *user_data)
{
  return NULL;
}

static grn_obj *
mruby_fin(grn_ctx *ctx, int nargs, grn_obj **args, grn_user_data *user_data)
{
  mrb_close(user_data->ptr);
  return NULL;
}

grn_rc
GRN_PLUGIN_INIT(grn_ctx *ctx)
{
  return ctx->rc;
}

grn_rc
GRN_PLUGIN_REGISTER(grn_ctx *ctx)
{
  grn_obj * const obj = grn_proc_create(ctx, "BuildMruby", 10, GRN_PROC_FUNCTION, /* todo: suitable proc type */
                                        mruby_init, mruby_next, mruby_fin, 0, NULL);
  if (obj == NULL) {
    GRN_PLUGIN_ERROR(ctx, GRN_UNKNOWN_ERROR, "grn_proc_create() failed"); /* todo: suitable error */
    return ctx->rc;
  }
  return GRN_SUCCESS;
}

grn_rc
GRN_PLUGIN_FIN(grn_ctx *ctx)
{
  return GRN_SUCCESS;
}
