.PHONY: apply destroy

default: apply

auth:
	@echo Checking for auth
	@export VAULT_ADDR=https://vault.lmhd.me && \
		vault token lookup >/dev/null || \
		vault login -method=oidc -path=okta_oidc > /dev/null

apply: auth
	@for a in $$(ls); do \
		if [ -d $$a ]; then \
			echo; \
			echo "========================================"; \
			echo "processing folder: $$a"; \
			echo "========================================"; \
			$(MAKE) -C $$a; \
		fi; \
	done;


destroy: auth
	@for a in $$(ls); do \
		if [ -d $$a ]; then \
			echo; \
			echo "========================================"; \
			echo "processing folder: $$a"; \
			echo "========================================"; \
			$(MAKE) destroy -C $$a; \
		fi; \
	done;
