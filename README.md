# Install Minikube

```
curl -LO https://storage.googleapis.com/minikube/releases/v1.33.1/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64
```

```
minikube version
minikube version: v1.33.1
commit: 5883c09216182566a63dff4c326a6fc9ed2982ff
```

```
minikube start --kubernetes-version 1.28.4
```

# Create test namespace

```
kubectl create ns bonita
```

# Deploy PostgreSQL

```
kubectl -n bonita create configmap db-scripts --from-file=db_scripts/
kubectl -n bonita apply -f postgresql.yaml
```

Test connection

```
kubectl -n bonita run psql-client --image postgres:15.7 --rm --tty -i --command -- /bin/bash
```

```
export PGPASSWORD=testpassword
psql -h postgres-db -p 5432 -U postgres postgres
postgres=# show max_connections;
 max_connections 
-----------------
 100
(1 ligne)

postgres=# \list
                                  List of databases
   Name    |   Owner    | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+------------+----------+------------+------------+-----------------------
 bizdata   | bizuser    | UTF8     | en_US.utf8 | en_US.utf8 | 
 bonita    | bonitauser | UTF8     | en_US.utf8 | en_US.utf8 | 
 postgres  | postgres   | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres   | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |            |          |            |            | postgres=CTc/postgres
 template1 | postgres   | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |            |          |            |            | postgres=CTc/postgres
(5 rows)
```


# Deploy Bonita

Add Docker registry credentials
```
DOCKER_SERVER=bonitasoft.jfrog.io
DOCKER_USERNAME=...
DOCKER_TOKEN=...
kubectl create secret docker-registry imagepullsecret --docker-server="${DOCKER_SERVER}" --docker-username="${DOCKER_USERNAME}" --docker-password="${DOCKER_TOKEN}" -n bonita
```

Request a Bonita license compatible with Kubernetes into the [Customer service center](https://csc.bonitacloud.bonitasoft.com/apps/CustomerServices)

Add this bonita license
```
cp BonitaSubscription-10.0-Test-20240312-20240908.lic bonita-license.lic
kubectl -n bonita create configmap bonita-license --from-file=bonita-license.lic
```

```
kubectl -n bonita create configmap bonita-scripts --from-file=bonita_scripts/
```

```
kubectl -n bonita apply -f bonita_secrets.yaml
kubectl -n bonita apply -f bonita_cm.yaml
kubectl -n bonita create serviceaccount bonitaserviceaccount
kubectl -n bonita apply -f bonita_rbac.yaml
kubectl -n bonita apply -f bonita_deployment.yaml
kubectl -n bonita apply -f bonita_service.yaml
```

Test connection
```
kubectl -n bonita port-forward service/bonita-test 8080:8080
```

Open http://127.0.0.1:8080 in your browser and use admin / myAdminSecret credentials.

# Scale up Bonita

Once bonita finished its startup
```
kubectl -n bonita logs --selector app.kubernetes.io/instance=bonita-test | grep "Server startup in" | jq .message
"Server startup in [20896] milliseconds"
```

```
kubectl -n bonita get deployment
NAME          READY   UP-TO-DATE   AVAILABLE   AGE
bonita-test   1/1     1            1           11m
```

You can scale up
```
kubectl -n bonita scale --current-replicas=1 --replicas=2 deployment/bonita-test
```

```
kubectl -n bonita get deployment
NAME          READY   UP-TO-DATE   AVAILABLE   AGE
bonita-test   2/2     2            2           16m
```

In case of success you will have this kind of message
```
kubectl -n bonita logs --selector app.kubernetes.io/instance=bonita-test | grep Members | jq .message
"[10.244.0.9]:5701 [bonita-test] [5.3.5] \n\nMembers {size:2, ver:2} [\n\tMember [10.244.0.9]:5701 - e633ecf6-a670-448b-bd69-f1fdab39299a this\n\tMember [10.244.0.10]:5701 - 90903a8a-c5d9-49f7-9021-e81e958e995a\n]\n"
```

# Clean test

```
kubectl delete ns bonita
```
