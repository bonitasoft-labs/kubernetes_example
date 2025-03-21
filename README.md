# Bonitasoft deployement

This repository provides a step-by-step guide to deploy Bonitasoft (version ≥10.2) on Kubernetes (tested with Kubernetes v1.30.9 and kubectl v1.30.9).

# Pre-requirements

* minikube (required only for local test)
* kubectl (at least v1.29.3)
* helm v3
* k9s v0.40.10 (recommended)

## Install Minikube

```bash
$ mkdir myTmp
$ cd myTmp
$ curl -LO https://storage.googleapis.com/minikube/releases/v1.34.0/minikube-linux-amd64
$ sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

```bash
$ minikube version
minikube version: v1.34.0
commit: 210b148df93a80eb872ecbeb7e35281b3c582c61
```

```bash
minikube start --kubernetes-version 1.30.9
```

## Install Helm

```bash
#cd myTmp
$ curl -LO https://get.helm.sh/helm-v3.17.1-linux-amd64.tar.gz
$ tar -zxvf helm-v3.17.1-linux-amd64.tar.gz
$ sudo mv linux-amd64/helm /usr/local/bin/helm
```

```bash
$ helm version
version.BuildInfo{Version:"v3.17.1", GitCommit:"980d8ac1939e39138101364400756af2bdee1da5", GitTreeState:"clean", GoVersion:"go1.23.5"}
```

## Install kubectl
> Based on [official documentation](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux).

```bash
#cd myTmp
$ curl -LO https://dl.k8s.io/release/v1.30.9/bin/linux/amd64/kubectl
$ curl -LO https://dl.k8s.io/release/v1.30.9/bin/linux/amd64/kubectl.sha256

$ echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
kubectl: OK

$ sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
$ kubectl version --client --output=yaml
clientVersion:
  buildDate: "2025-01-15T14:41:47Z"
  compiler: gc
  gitCommit: a87cd6906120a367bf6787420e943103a463acba
  gitTreeState: clean
  gitVersion: v1.30.9
  goVersion: go1.22.10
  major: "1"
  minor: "30"
  platform: linux/amd64
kustomizeVersion: v5.0.4-0.20230601165947-6ce0bf390ce3
```

## k9s

```bash
#cd myTmp
$ curl https://github.com/derailed/k9s/releases/download/v0.40.10/k9s_linux_arm64.deb
$ sudo apt install ./k9s_linux_amd64.deb
```

### Clean temp folder

```bash
$ rm -Rf ~/myTmp
```

# Prepare deployment

## Create test namespace

```bash
kubectl create ns bonita
```

## Deploy PostgreSQL

```bash
kubectl -n bonita create configmap db-scripts --from-file=db_scripts/
kubectl -n bonita apply -f postgresql.yaml
```

### Test connection

```bash
kubectl -n bonita run psql-client --image postgres:16.4 --rm --tty -i --command -- /bin/bash
```

```bash
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

## 1. Add Docker registry credentials

```bash
$ DOCKER_SEVER=bonitasoft.jfrog.io
$ DOCKER_USERNAME=myUserName
$ DOCKER_TOKEN=myPassword
$ kubectl create secret docker-registry imagepullsecret --docker-server="${DOCKER_SEVER}" --docker-username="${DOCKER_USERNAME}" --docker-password="${DOCKER_TOKEN}" -n bonita
```

## 2. Add bonita license

```bash
$ cp BonitaSubscription-10.2-Test-20250303-20250830.lic license.lic
$ kubectl -n bonita create secret generic bonita-license --from-file=license.lic
```

## 3. Deploy Bonita using helm
```bash
$ helm dependency build helm/bonita-custom

$ helm upgrade --install \
  bonita-test \
  -n bonita \
  helm/bonita-custom \
  -f helm/values-test.yaml
```

## 4. Test connection
Make sure the port `80` is available on your localhost.

```bash
$ sudo -E kubectl --namespace bonita port-forward service/bonita-test-ui-proxy 80:80
```

Open http://127.0.0.1 in your browser and use admin / myAdminSecret credentials.

# Scale up Bonita

Once bonita finished its startup

```bash
$ kubectl -n bonita logs --tail=-1 --selector app=runtime | grep "Server startup in" | jq .message
"Server startup in [22712] milliseconds"
```

```bash
$ kubectl -n bonita get deployment --selector app=runtime
NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
bonita-test-engine       1/1     1            1           11m
```

You can scale up

```bash
kubectl -n bonita scale --current-replicas=1 --replicas=2 deployment/bonita-test-engine
```

```bash
$ kubectl -n bonita get deployment --selector app=runtime
NAME          READY   UP-TO-DATE   AVAILABLE   AGE
bonita-test-engine   2/2     2            2           16m
```

In case of success you will have this kind of message

```bash
$ kubectl -n bonita logs --tail=-1 --selector app=runtime | grep Members | jq .message
"[10.244.0.62]:5701 [bonita-test-hazelcast] [5.4.0] \n\nMembers {size:1, ver:1} [\n\tMember [10.244.0.62]:5701 - 28367a58-bbc7-4c4f-8ca3-ef4372cab435 this\n]\n"
"[10.244.0.62]:5701 [bonita-test-hazelcast] [5.4.0] \n\nMembers {size:2, ver:2} [\n\tMember [10.244.0.62]:5701 - 28367a58-bbc7-4c4f-8ca3-ef4372cab435 this\n\tMember [10.244.0.65]:5701 - ffa1837a-af46-4ce4-a7a6-4f2a513f2415\n]\n"
"[10.244.0.65]:5701 [bonita-test-hazelcast] [5.4.0] \n\nMembers {size:2, ver:2} [\n\tMember [10.244.0.62]:5701 - 28367a58-bbc7-4c4f-8ca3-ef4372cab435\n\tMember [10.244.0.65]:5701 - ffa1837a-af46-4ce4-a7a6-4f2a513f2415 this\n]\n"
```

# Clean test

```bash
$ kubectl delete ns bonita
```
