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
#include "db.h"

#ifdef GRN_WITH_MRUBY
# include <mruby/proc.h>
# include <mruby/compile.h>
#endif

#ifdef GRN_WITH_MRUBY
void
grn_ctx_impl_mrb_init(grn_ctx *ctx)
{
  const char *grn_mruby_enabled;
  grn_mruby_enabled = getenv("GRN_MRUBY_ENABLED");
  if (grn_mruby_enabled && strcmp(grn_mruby_enabled, "yes") == 0) {
    const char *mruby_plugin_name = "scaninfo_builders/mruby";
    char *path;
    path = grn_plugin_find_path(ctx, mruby_plugin_name);
    if (path) {
      grn_proc_ctx *pctx_ptr;
      GRN_FREE(path);
      grn_plugin_register(ctx, mruby_plugin_name);
      pctx_ptr = GRN_MALLOC(sizeof(grn_proc_ctx));
      pctx_ptr->user_data.ptr = NULL;
      pctx_ptr->proc = grn_ctx_get(ctx, "BuildMruby", 10);
      pctx_ptr->proc->funcs[PROC_INIT](ctx, 0, NULL, &pctx_ptr->user_data);
      ctx->impl->mrb = pctx_ptr;
    }
  } else {
    ctx->impl->mrb = NULL;
  }
}

void
grn_ctx_impl_mrb_fin(grn_ctx *ctx)
{
  if (ctx->impl->mrb) {
    grn_proc_ctx *pctx_ptr = ctx->impl->mrb;
    pctx_ptr->proc->funcs[PROC_FIN](ctx, 0, NULL, &pctx_ptr->user_data);
    GRN_FREE(pctx_ptr);
    ctx->impl->mrb = NULL;
  }
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
