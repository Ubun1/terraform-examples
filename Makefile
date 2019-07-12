WORKDIR := $(abspath .)
CASES_PATHS := $(sort $(dir $(wildcard $(WORKDIR)/cases/*/*/)))
CASES_NAMES := $(foreach PATH, $(CASES_PATHS), $(lastword $(subst /, ,$(PATH))))

TERRAFORM != which terraform
TRASH_FILES := terraform.tfstate terraform.tfstate.backup crash.log

VENV ?= . $(WORKDIR)/.venv/bin/activate && .venv/bin
PIP ?= $(VENV)/pip
PYTHON ?= $(VENV)/python

define EXCLUDE_CASE_NAMES
# FIXME: 'C2DEVEL-3389'
aws_ami_from_instance
# FIXME: 'C2DEVEL-4478'
aws_customer_gateway
aws_volume_attachment
endef

.PHONY: all clean init show-cases clean-all lint-rst lint-terraform
.SILENT: all clean init show-cases clean-all lint-rst lint-terraform

all: clean
	$(foreach case, \
		$(CASES_NAMES), \
			$(if $(filter $(case),$(EXCLUDE_CASE_NAMES)),, \
				$(MAKE) plan-$(case) || exit $$; \
				$(MAKE) apply-$(case) || exit $$; \
				$(MAKE) destroy-$(case) || exit $$; \
		) \
	)

init:
ifeq ($(wildcard .venv/.*),)
	mkdir .venv
	virtualenv -p python3 .venv
endif
	$(TERRAFORM) init
	$(PIP) install rstcheck

show-cases:
	find ./cases/ -mindepth 2 -name README.rst | \
		awk -F'/' '{print $$(NF-1)}'

clean: COMMON_RESOURCES_NAMES != ls $(WORKDIR)/common
clean: LINKS != find -L $(WORKDIR)/cases -xtype l -print0 | xargs -0 -i% basename %
clean:
	$(foreach to_del,\
		$(TRASH_FILES) $(LINKS),\
			$(if $(filter $(to_del), $(COMMON_RESOURCES_NAMES)),,\
				find $(WORKDIR)/cases -name $(to_del) -delete ; \
				)\
	)

clean-all: clean
	rm -rf $(WORKDIR)/.terraform/

define TERRAFORM_CASE_CMD

.PHONY: $(1)-$(lastword $(subst /, ,$(2)))
$(1)-$(lastword $(subst /, ,$(2))):
	cd $(2) && \
		ln -sf $(WORKDIR)/.terraform $(2) && \
		ln -sf $(WORKDIR)/main.tf $(2)provider.tf && \
		ln -sf $(WORKDIR)/terraform.tfvars $(2) && \
		bash -c 'yes yes | TF_LOG=$(TF_LOG) $(TERRAFORM) $(1)'
endef

$(foreach path,$(CASES_PATHS),$(eval $(call TERRAFORM_CASE_CMD,plan,$(path))))
$(foreach path,$(CASES_PATHS),$(eval $(call TERRAFORM_CASE_CMD,apply,$(path))))
$(foreach path,$(CASES_PATHS),$(eval $(call TERRAFORM_CASE_CMD,destroy,$(path))))
$(foreach path,$(CASES_PATHS),$(eval $(call TERRAFORM_CASE_CMD,validate,$(path))))

lint-rst: init
	$(VENV)/rstcheck -r .

lint-terraform: init create-stub-tfvars $(foreach name,$(CASES_NAMES),validate-$(name))

create-stub-tfvars: ; cp terraform.tfvars{.example,}
