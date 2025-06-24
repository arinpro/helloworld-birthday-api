run:
	uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

test:
	PYTHONPATH=. pytest --maxfail=1 --disable-warnings -q

cloudnativepg-operator:
	kubectl apply --server-side --force-conflicts -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.26/releases/cnpg-1.26.0.yaml

flyway-cm:
	kubectl create configmap flyway-conf --from-file=flyway/flyway.conf --dry-run=client -o yaml | kubectl apply -f -
	kubectl create configmap flyway-sql --from-file=flyway/sql/ --dry-run=client -o yaml | kubectl apply -f -

migrate:
	kubectl apply -f k8s/base/flyway-job.yaml

build:
	eval "$$(minikube docker-env)" && docker build -t helloworld-birthday-api:latest .

lint:
	flake8 app/

.PHONY: minikube-deploy minikube-destroy

minikube-deploy:
	./deploy-minikube.sh

minikube-destroy:
	./destroy-minikube.sh
