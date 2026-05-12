.PHONY: test verify-docs verify-scripts

test: verify-docs verify-scripts

verify-docs:
	./scripts/verify-skills.sh

verify-scripts:
	bash -n scripts/verify-skills.sh
	echo "bash -n: ok"
	@if command -v shellcheck >/dev/null 2>&1; then \
	  shellcheck scripts/*.sh && echo "shellcheck: ok"; \
	else \
	  echo "shellcheck: skipped (not installed)"; \
	fi
