PKL ?= pkl
OUT ?= out
VERSION ?= 0.1.0

.PHONY: render validate package
render:
	@mkdir -p "$(OUT)"
	@$(PKL) eval -o "$(OUT)/compose.yaml" examples/compose.pkl

validate: render
	@$(PKL) eval examples/compose.pkl >/dev/null
	@echo "pkl-docker validation succeeded."

package:
	@PKL_PACKAGE_VERSION="$(VERSION)" $(PKL) project package --output-path dist
