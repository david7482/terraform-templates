check:
ifeq ($(ENV),)
	$(error "Could not read env variable: ENV")
endif
ifeq ($(findstring $(ENV), apne1 usea1),)
	$(error "Could not read valid env variable: ENV (Need to be 'apne1' or 'usea1')")
endif

init:
	terraform init

plan: check
	terraform workspace select $(ENV)
	terraform plan -var-file configs/$(ENV).tfvars

apply: check
	terraform workspace select $(ENV)
	terraform apply -var-file configs/$(ENV).tfvars

destroy: check
	terraform workspace select $(ENV)
	terraform destroy -var-file configs/$(ENV).tfvars