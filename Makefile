apply:
	git pull
	terraform init
	terraform apply

destroy:
	git pull
	terraform init
	terraform destroy

