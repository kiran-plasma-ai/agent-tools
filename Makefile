# make check — deterministic gate for the shell/python in this repo.
# shellcheck runs when installed; syntax checks always run.

SH_FILES := install.sh bin/nodeshell bin/omp-debug-trigger bin/omp-debug-dispatch \
            bin/omp-debug-kitty bin/omp-debug-new-env bin/git bin/cargo \
            examples/envs/myproj
PY_FILES := bin/mdrecall bin/systemd-urun kitty-debug/auth.py

.PHONY: check
check:
	@for f in $(SH_FILES); do \
		case "$$(head -1 $$f)" in \
			*bash*) bash -n $$f || exit 1 ;; \
			*)     sh -n $$f   || exit 1 ;; \
		esac; \
	done
	@python3 -m py_compile $(PY_FILES)
	@if command -v shellcheck >/dev/null; then \
		shellcheck -S warning $(SH_FILES); \
	else \
		echo "shellcheck not installed — syntax checks only"; \
	fi
	@echo "check: ok"
