.PHONY: catalog validate check audit

catalog:
	python3 scripts/build-provenance.py
	python3 scripts/build-skill-audit.py
	python3 scripts/build-catalog.py

validate:
	python3 scripts/validate-repo.py
	python3 scripts/build-provenance.py --check
	python3 scripts/build-skill-audit.py --check
	python3 scripts/build-catalog.py --check

check: validate

audit:
	python3 scripts/validate-repo.py --audit
