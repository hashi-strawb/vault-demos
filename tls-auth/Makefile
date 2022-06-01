.PHONY: apply destroy clear-state

default: apply

apply:
	terraform apply -auto-approve


destroy:
	terraform destroy -auto-approve


clear-state:
	terraform state list | xargs -n 1 terraform state rm

