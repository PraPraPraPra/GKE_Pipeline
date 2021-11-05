#!/bin/bash
# A script to configure a Cluster with Istio and Postgres
# Should be deployed at start-up.

#TODO: Should User Vars instead of hardcoding?

#Fetching credentials
gcloud container clusters get-credentials fernando-cluster12345 --region us-west2-a --project skillful-radar-326013

#Installing Istio
#Why is profile demo? Why skip-confirmation?
istioctl install --set profile=demo --skip-confirmation

#Should Use Plan+Validate+Apply instead of just apply?
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.8/samples/addons/prometheus.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.8/samples/addons/jaeger.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.8/samples/addons/grafana.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.8/samples/addons/kiali.yaml

###
#if [ ! -e "istio-grafana.yaml" ]
#then wget wget https://gitlab.com/b.a.lopes/scrumify-challenge-infrastructure/-/raw/main/istio/istio-grafana.yaml
#fi
###

###
wget https://gitlab.com/b.a.lopes/scrumify-challenge-infrastructure/-/raw/main/istio/istio-grafana.yaml
wget https://gitlab.com/b.a.lopes/scrumify-challenge-infrastructure/-/raw/main/istio/istio-prometheus.yaml
wget https://gitlab.com/b.a.lopes/scrumify-challenge-infrastructure/-/raw/main/istio/istio-kiali.yaml

sed -i 's/##CLUSTER_NAME##/fernando-cluster12345/g' istio-prometheus.yaml 
sed -i 's/##CLUSTER_NAME##/fernando-cluster12345/g' istio-kiali.yaml 
sed -i 's/##CLUSTER_NAME##/fernando-cluster12345/g' istio-grafana.yaml 

kubectl apply -f istio-grafana.yaml 
kubectl apply -f istio-kiali.yaml 
kubectl apply -f istio-prometheus.yaml

rm istio-grafana.yaml 
rm istio-kiali.yaml 
rm istio-prometheus.yaml
###

###
wget https://gitlab.com/b.a.lopes/scrumify-challenge-infrastructure/-/raw/main/namespace.yaml
sed -i 's/##ENVIRONMENT_NAME##/dev-fernando-cluster12345/g' namespace.yaml 
kubectl apply -f namespace.yaml 
rm namespace.yaml

wget https://gitlab.com/b.a.lopes/scrumify-challenge-infrastructure/-/raw/main/postgres/postgres-secret.yaml
sed -i 's/##ENVIRONMENT_NAME##/dev-fernando-cluster12345/g' postgres-secret.yaml 
sed -i 's/##POSTGRES_PASSWORD##/pashword/g' postgres-secret.yaml 
kubectl apply -f postgres-secret.yaml -n dev-fernando-cluster12345
rm postgres-secret.yaml
###

###
wget https://gitlab.com/b.a.lopes/scrumify-challenge-infrastructure/-/raw/main/postgres/postgres-storage.yaml
sed -i 's/##ENVIRONMENT_NAME##/dev-fernando-cluster12345/g' postgres-storage.yaml 
kubectl apply -f postgres-storage.yaml -n dev-fernando-cluster12345
rm postgres-storage.yaml
###

#Should we confirm?
kubectl api-resources
kubectl get pv -A
###

###
wget https://gitlab.com/b.a.lopes/scrumify-challenge-infrastructure/-/raw/main/postgres/postgres-deployment.yaml
sed -i 's/##ENVIRONMENT_NAME##/dev-fernando-cluster12345/g' postgres-deployment.yaml 
kubectl apply -f postgres-deployment.yaml -n dev-fernando-cluster12345
rm postgres-deployment.yaml
###

###
wget https://gitlab.com/b.a.lopes/scrumify-challenge-infrastructure/-/raw/main/postgres/postgres-service.yaml
kubectl apply -f postgres-service.yaml -n dev-fernando-cluster12345
rm postgres-service.yaml
###

###
wget https://gitlab.com/b.a.lopes/scrumify-challenge-infrastructure/-/raw/main/postgres/postgres-ilb-service.yaml
kubectl apply -f postgres-ilb-service.yaml -n dev-fernando-cluster12345
rm postgres-ilb-service.yaml
###

###
# grep -o doesn't print the whole line, just the match that we want.
export POD_NAME=$(kubectl --namespace=dev-fernando-cluster12345 get pods -l app=postgres | grep  -o "postgres\S*")
kubectl  --namespace=dev-fernando-cluster12345 exec --stdin --tty $POD_NAME -- /bin/bash
#Does this work? Probably...
psql -h localhost -U postgresadmin -p 5432 postgresdb
CREATE SCHEMA IF NOT EXISTS scrumify;
ALTER SCHEMA scrumify OWNER TO postgresadmin;
\q
exit
###