# Makefile for slurm.cluster deployment

# Macros
DEPLOY_OPTIONS :=

# Required Macros
ifndef CLUSTER_NAME
  $(error CLUSTER_NAME is not set)
endif

ifndef MASTER_NAME
  $(error MASTER_NAME is not set)
endif

# Check for CLUSTER_LOCATION
ifndef CLUSTER_LOCATION
  CLUSTER_LOCATION := $(CURDIR)
  FINAL_CLUSTER_LOCATION := $(CLUSTER_LOCATION)
else
  FINAL_CLUSTER_LOCATION := $(CLUSTER_LOCATION)/$(CLUSTER_NAME
  DEPLOY_OPTIONS = $(FINAL_CLUSTER_LOCATION)
endif

# Check if Slurm path specified, set to /usr/local/bin if not
SLURM_LINK ?= '/usr/local/bin'

# Set SLURM_USER to 'Slurm' if not set
SLURM_USER ?= Slurm

# Set SLURM_GROUP to 'Slurm' if not sett
SLURM_GROUP ?= Slurm

# Set DB_USER to default value if not set
DB_USER ?= default_db_user

# Set JWK_KEY to default value if not set
JWK_KEY ?= default_jwk_key

# Set DB_PASSWD to a random value if not set
DB_PASSWD ?= $(shell head -c 16 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9' | head -c 16)

# Set JWK_PASSW to a random value if not set
JWK_PASSW ?= $(shell head -c 16 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9' | head -c 16)

# Check for BKUP_MASTER
ifndef BKUP_MASTER
  DEPLOY_OPTIONS += no.bkup.master
else
  DEPLOY_OPTIONS += set.bkup.master
endif

# Check for DB_SERVER
ifdef DB_SERVER
  DEPLOY_OPTIONS += add.db.settings
else
  DEPLOY_OPTIONS += rm.db.settings
endif

# Check for PYTHON_PATH
ifdef PYTHON_PATH
  DEPLOY_OPTIONS += setup.python
endif

# Check for NO_SYNC_TOOLS
ifndef NO_SYNC_TOOLS
  DEPLOY_OPTIONS += sync.tools
endif

# Set the config paths
SLURM_CONF_DIR := $(FINAL_CLUSTER_LOCATION)/etc
SLURM_SERVICES_PATH := $(FINAL_CLUSTER_LOCATION)/services/slurm.service
SLURM_TOOLS_PATH := $(FINAL_CLUSTER_LOCATION)/tools
SLURM_CONF_FILE := $(SLURM_CONF_DIR)/slurm.conf
SLURMDBD_CONF_FILE := $(SLURM_CONF_DIR)/slurmdbd.conf
SLURM_JWKS_FILE := $(SLURM_CONF_DIR)/slurm.jwks

# Target Entries
.PHONY: deploy sync.tools add.master no.cp setup.python add.db.settings rm.db.settings

deploy: $(DEPLOY_OPTIONS)
	@echo "Deployment steps: $(DEPLOY_OPTIONS)"
	@echo "Deploying cluster $(CLUSTER_NAME) with master $(MASTER_NAME)"
	sed -i'.bkup' "s:{CLUSTER_NAME}:$(CLUSTER_NAME):" $(SLURM_CONF_FILE)
	sed -i'.bkup' "s:{MASTER_NAME}:$(MASTER_NAME):" $(SLURM_CONF_FILE)
	sed -i'.bkup' "s:{SLURM_USER}:$(SLURM_USER):" $(SLURM_CONF_FILE)
	sed -i'.bkup' "s:<KEY_ID>:i$(JWK_KEY):" $(SLURM_JWKS_FILE)
	sed -i'.bkup' "s:<KEY_VALUE>:$(JWK_PASSW):" $(SLURM_JWKS_FILE)
	chmod 440 $(SLURM_JWKS_FILE)
	chown $(SLURM_USER):$(SLURM_GROUP) $(SLURM_JWKS_FILE)

$(FINAL_CLUSTER_LOCATION):
	@echo "Setting up final cluster location..."
	su $(SLURM_USER) -c "cp -rf $(CURDIR) $(FINAL_CLUSTER_LOCATION)"

sync.tools:
	@echo "Syncing tools..."
	-rm -rf $(CURDIR)/tools
	git clone https://github.com/laugesen11/slurm.tools.git $(CURDIR)/tools
	rm -rf $(CURDIR)/tools/.git

setup.python:
	@echo "Setting up Python environment..."
	$(PYTHON_PATH)/bin/python3 -m venv $(FINAL_CLUSTER_LOCATION)/slurm_python
	$(FINAL_CLUSTER_LOCATION)/slurm_python/bin/pip install ansible

add.db.settings:
	@echo "Adding DB settings..."
	sed -i'.bkup' '/^AccountingStorageHost/cAccountingStorageHost=$(DB_SVR_NAME)' $(SLURM_CONF_FILE)
	sed -i'.bkup' '/^AccountingStorageUser/cAccountingStorageUser=$(DB_USER)' $(SLURM_CONF_FILE)
	sed -i'.bkup' '/^StorageUser/cStorageUser=$(DB_USER)' $(SLURMDBD_CONF_FILE)
	sed -i'.bkup' '/^StoragePass/cStoragePass=$(DB_PASSWD)' $(SLURMDBD_CONF_FILE)
	sed -i'.bkup' '/^StorageLoc/cStorageLoc=$(DB_NAME)' $(SLURMDBD_CONF_FILE)
	chown $(SLURM_USER):$(SLURM_GROUP) $(SLURMDBD_CONF_FILE)
	chmod 600 $(SLURMDBD_CONF_FILE)
rm.db.settings:
	@echo "Removing DB settings..."
	sed -i'.bkup' '/^Accounting/s/^/#/' $(SLURM_CONF_FILE)
	sed -i'.bkup' '/^JobAcct/s/^/#/' $(SLURM_CONF_FILE)

no.bkup.master:
	@echo "Removing backup master line..."
	sed -i'.bkup' '/^SlurmctldHost={BKUP_MASTER}/d' $(SLURM_CONF_FILE)

set.bkup.master:
	@echo "Adding backup master line..."
	sed -i'.bkup' 's/{BKUP_MASTER}/$(BKUP_MASTER)/' $(SLURM_CONF_FILE)
