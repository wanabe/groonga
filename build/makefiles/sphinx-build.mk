SPHINXOPTS    =
PAPER         =

SPHINX_DIR = $(abs_top_builddir)/doc/sphinx
SPHINX_BUILD = $(SPHINX_DIR)/sphinx-build.py
SPHINX_BUILD_COMMAND = PYTHONPATH="$(SPHINX_DIR):$$PYTHONPATH" python $(SPHINX_BUILD)

.PHONY: sphinx-ensure-updated

$(SPHINX_BUILD):
	hg clone https://bitbucket.org/birkenfeld/sphinx $(SPHINX_DIR)

sphinx-ensure-updated: $(SPHINX_BUILD)
	if ! $(SPHINX_BUILD_COMMAND) 2>&1 | head -1 | grep v1.1 -q > /dev/null; then					\
	    hg pull $(SPHINX_DIR);						\
	fi


# (cd ../../doc; find source -type f -not -name '*.pyc' | sort | sed -e 's,^,\t$(top_srcdir)/doc/,g')
source_files =					\
	$(top_srcdir)/doc/source/__init__.py						 \
	$(top_srcdir)/doc/source/characteristic.txt						 \
	$(top_srcdir)/doc/source/command_version.txt					 \
	$(top_srcdir)/doc/source/commands.txt						 \
	$(top_srcdir)/doc/source/commands/cache_limit.txt					 \
	$(top_srcdir)/doc/source/commands/check.txt						 \
	$(top_srcdir)/doc/source/commands/clearlock.txt					 \
	$(top_srcdir)/doc/source/commands/column_create.txt					 \
	$(top_srcdir)/doc/source/commands/column_list.txt					 \
	$(top_srcdir)/doc/source/commands/column_remove.txt					 \
	$(top_srcdir)/doc/source/commands/define_selector.txt				 \
	$(top_srcdir)/doc/source/commands/defrag.txt					 \
	$(top_srcdir)/doc/source/commands/delete.txt					 \
	$(top_srcdir)/doc/source/commands/dump.txt						 \
	$(top_srcdir)/doc/source/commands/load.txt						 \
	$(top_srcdir)/doc/source/commands/log_level.txt					 \
	$(top_srcdir)/doc/source/commands/log_put.txt					 \
	$(top_srcdir)/doc/source/commands/log_reopen.txt					 \
	$(top_srcdir)/doc/source/commands/quit.txt						 \
	$(top_srcdir)/doc/source/commands/select.txt					 \
	$(top_srcdir)/doc/source/commands/shutdown.txt					 \
	$(top_srcdir)/doc/source/commands/status.txt					 \
	$(top_srcdir)/doc/source/commands/suggest.txt					 \
	$(top_srcdir)/doc/source/commands/table_create.txt					 \
	$(top_srcdir)/doc/source/commands/table_list.txt					 \
	$(top_srcdir)/doc/source/commands/table_remove.txt					 \
	$(top_srcdir)/doc/source/commands/view_add.txt					 \
	$(top_srcdir)/doc/source/commands_not_implemented/add.txt				 \
	$(top_srcdir)/doc/source/commands_not_implemented/get.txt				 \
	$(top_srcdir)/doc/source/commands_not_implemented/set.txt				 \
	$(top_srcdir)/doc/source/conf.py							 \
	$(top_srcdir)/doc/source/developer.txt						 \
	$(top_srcdir)/doc/source/developer/com.txt						 \
	$(top_srcdir)/doc/source/developer/document.txt					 \
	$(top_srcdir)/doc/source/developer/query.txt					 \
	$(top_srcdir)/doc/source/developer/test.txt						 \
	$(top_srcdir)/doc/source/example/tutorial01-1.log					 \
	$(top_srcdir)/doc/source/example/tutorial01-10.log					 \
	$(top_srcdir)/doc/source/example/tutorial01-11.log					 \
	$(top_srcdir)/doc/source/example/tutorial01-12.log					 \
	$(top_srcdir)/doc/source/example/tutorial01-13.log					 \
	$(top_srcdir)/doc/source/example/tutorial01-14.log					 \
	$(top_srcdir)/doc/source/example/tutorial01-15.log					 \
	$(top_srcdir)/doc/source/example/tutorial01-16.log					 \
	$(top_srcdir)/doc/source/example/tutorial01-17.log					 \
	$(top_srcdir)/doc/source/example/tutorial01-2.log					 \
	$(top_srcdir)/doc/source/example/tutorial01-3.log					 \
	$(top_srcdir)/doc/source/example/tutorial01-4.log					 \
	$(top_srcdir)/doc/source/example/tutorial01-5.log					 \
	$(top_srcdir)/doc/source/example/tutorial01-6.log					 \
	$(top_srcdir)/doc/source/example/tutorial01-7.log					 \
	$(top_srcdir)/doc/source/example/tutorial01-8.log					 \
	$(top_srcdir)/doc/source/example/tutorial01-9.log					 \
	$(top_srcdir)/doc/source/example/tutorial02-1.log					 \
	$(top_srcdir)/doc/source/example/tutorial02-2.log					 \
	$(top_srcdir)/doc/source/example/tutorial02-3.log					 \
	$(top_srcdir)/doc/source/example/tutorial03-1.log					 \
	$(top_srcdir)/doc/source/example/tutorial03-2.log					 \
	$(top_srcdir)/doc/source/example/tutorial03-3.log					 \
	$(top_srcdir)/doc/source/example/tutorial04-1.log					 \
	$(top_srcdir)/doc/source/example/tutorial04-2.log					 \
	$(top_srcdir)/doc/source/example/tutorial04-3.log					 \
	$(top_srcdir)/doc/source/example/tutorial04-4.log					 \
	$(top_srcdir)/doc/source/example/tutorial04-5.log					 \
	$(top_srcdir)/doc/source/example/tutorial04-6.log					 \
	$(top_srcdir)/doc/source/example/tutorial04-7.log					 \
	$(top_srcdir)/doc/source/example/tutorial05-1.log					 \
	$(top_srcdir)/doc/source/example/tutorial05-2.log					 \
	$(top_srcdir)/doc/source/example/tutorial05-3.log					 \
	$(top_srcdir)/doc/source/example/tutorial05-4.log					 \
	$(top_srcdir)/doc/source/example/tutorial05-5.log					 \
	$(top_srcdir)/doc/source/example/tutorial05-6.log					 \
	$(top_srcdir)/doc/source/example/tutorial06-1.log					 \
	$(top_srcdir)/doc/source/example/tutorial06-2.log					 \
	$(top_srcdir)/doc/source/example/tutorial06-3.log					 \
	$(top_srcdir)/doc/source/example/tutorial06-4.log					 \
	$(top_srcdir)/doc/source/example/tutorial06-5.log					 \
	$(top_srcdir)/doc/source/example/tutorial06-6.log					 \
	$(top_srcdir)/doc/source/example/tutorial06-7.log					 \
	$(top_srcdir)/doc/source/example/tutorial07-1.log					 \
	$(top_srcdir)/doc/source/example/tutorial07-2.log					 \
	$(top_srcdir)/doc/source/example/tutorial07-3.log					 \
	$(top_srcdir)/doc/source/example/tutorial07-4.log					 \
	$(top_srcdir)/doc/source/example/tutorial08-1.log					 \
	$(top_srcdir)/doc/source/example/tutorial10-1.log					 \
	$(top_srcdir)/doc/source/example/tutorial10-10.log					 \
	$(top_srcdir)/doc/source/example/tutorial10-2.log					 \
	$(top_srcdir)/doc/source/example/tutorial10-3.log					 \
	$(top_srcdir)/doc/source/example/tutorial10-4.log					 \
	$(top_srcdir)/doc/source/example/tutorial10-5.log					 \
	$(top_srcdir)/doc/source/example/tutorial10-6.log					 \
	$(top_srcdir)/doc/source/example/tutorial10-7.log					 \
	$(top_srcdir)/doc/source/example/tutorial10-8.log					 \
	$(top_srcdir)/doc/source/example/tutorial10-9.log					 \
	$(top_srcdir)/doc/source/execfile.txt						 \
	$(top_srcdir)/doc/source/expr.txt							 \
	$(top_srcdir)/doc/source/functions.txt						 \
	$(top_srcdir)/doc/source/functions/edit_distance.txt				 \
	$(top_srcdir)/doc/source/functions/geo_distance.txt					 \
	$(top_srcdir)/doc/source/functions/geo_in_circle.txt				 \
	$(top_srcdir)/doc/source/functions/geo_in_rectangle.txt				 \
	$(top_srcdir)/doc/source/functions/now.txt						 \
	$(top_srcdir)/doc/source/functions/rand.txt						 \
	$(top_srcdir)/doc/source/grnslap.txt						 \
	$(top_srcdir)/doc/source/grntest.txt						 \
	$(top_srcdir)/doc/source/http.txt							 \
	$(top_srcdir)/doc/source/index.txt							 \
	$(top_srcdir)/doc/source/install.txt						 \
	$(top_srcdir)/doc/source/limitations.txt						 \
	$(top_srcdir)/doc/source/news.txt							 \
	$(top_srcdir)/doc/source/process.txt						 \
	$(top_srcdir)/doc/source/pseudo_column.txt						 \
	$(top_srcdir)/doc/source/rdoc.py							 \
	$(top_srcdir)/doc/source/reference.txt						 \
	$(top_srcdir)/doc/source/spec.txt							 \
	$(top_srcdir)/doc/source/spec/search.txt						 \
	$(top_srcdir)/doc/source/textile.py							 \
	$(top_srcdir)/doc/source/troubleshooting.txt					 \
	$(top_srcdir)/doc/source/troubleshooting/different_results_with_the_same_keyword.txt \
	$(top_srcdir)/doc/source/tutorial.txt						 \
	$(top_srcdir)/doc/source/tutorial/tutorial01.txt					 \
	$(top_srcdir)/doc/source/tutorial/tutorial02.txt					 \
	$(top_srcdir)/doc/source/tutorial/tutorial03.txt					 \
	$(top_srcdir)/doc/source/tutorial/tutorial04.txt					 \
	$(top_srcdir)/doc/source/tutorial/tutorial05.txt					 \
	$(top_srcdir)/doc/source/tutorial/tutorial06.txt					 \
	$(top_srcdir)/doc/source/tutorial/tutorial07.txt					 \
	$(top_srcdir)/doc/source/tutorial/tutorial08.txt					 \
	$(top_srcdir)/doc/source/tutorial/tutorial09.txt					 \
	$(top_srcdir)/doc/source/tutorial/tutorial10.txt					 \
	$(top_srcdir)/doc/source/type.txt							 \
	$(top_srcdir)/doc/source/update_execution_example.py
