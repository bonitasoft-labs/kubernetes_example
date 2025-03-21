# Bonita Helm Chart

This chart bootstraps a [Bonita Runtime](https://documentation.bonitasoft.com/bonita/2024.3/what-is-bonita) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.12+
- Helm 3.1.0

## Installing the Chart

To install the chart with the release name `my-release`:

```console
helm install my-release helm/bonita --version 0.0.1
```

**_NOTE:_** --version is optional, if you omit helm take the latest version

The command deploys Bonita Docker image on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components of the helm release.

## Parameters

### Common parameters
| Name                                            | Description                                                                       | Default                     |
| ----------------------------------------------- | --------------------------------------------------------------------------------- | --------------------------- |
| `nameOverride`                                  | Replacing the chart name with another new name                                    | `""`                        |
| `fullnameOverride`                              | Replace the full distinguished name with another name                             | `""`                        |
| `replicaCount`                                  | Specify the number of replicas for the Bonita Pods                                | `1`                         |
| `podAnnotations`                                | Annotations to add in the bonita pod                                              | `{}`                        |
| `podSecurityContext`                            | SecurityContext to add in the bonita pod                                          | `{}`                        |
| `podInitContainers`                             | Initcontainers to add in the bonita pod                                           | `[]`                        |
| `podVolumes`                                    | Volumes to add in thebBonita pod                                                  | `[]`                        |
| `containersSecurityContext`                     | SecurityContext to add to the bonita container                                    | `{}`                        |
| `resources`                                     | Resource limits for Bonita pods                                                   | `{}`                        |
| `nodeSelector`                                  | Node selector for Bonita pods ([doc](https://kubernetes.io/docs/user-guide/node-selection/))| `{}`              |
| `tolerations`                                   | Tolerations for Bonita pods ([doc](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/))| `{}`|
| `affinity`                                      | Assign custom affinity rules to the Bonita pods                                   | `{}`                        |
| `licenseSecretName`                             | Name of secret containing license                                                 | `""`                        |
| `customConfigScripts`                           | Map of scripts to customize bonita configuration                                  | `{}`                        |
| `customInitScripts`                             | Map of scripts to execute before lauching tomcat                                  | `{}`                        |
| `timeZone`                                      | Timezone to set in container (`TZ` environment variable)                          | `""`                        |
| `progradePolicy`                                | Java Security Policy configuration to apply                                       | `""`                        |


### Accesslogs parameters
| Name                                            | Description                                                                       | Default                     |
| ----------------------------------------------- | --------------------------------------------------------------------------------- | --------------------------- |
| `accesslogs.stdoutEnabled`                      | Enable printing logs to container stdout                                          | `true`                      |
| `accesslogs.filesEnabled`                       | Enable printing logs to files                                                     | `false`                     |
| `accesslogs.filesPath`                          | Path of directory containing logs (mandatory if filesEnabled=true)                | `""`                        |
| `accesslogs.filesAppendHostname`                | Enable appending hostname to logs files                                           | `true`                      |
| `accesslogs.filesMaxDays`                       | Maximum age of logs files, olders files are deleted                               | `""`                        |


### Image parameters
| Name                                            | Description                                                                       | Default                     |
| ----------------------------------------------- | --------------------------------------------------------------------------------- | --------------------------- |
| `image.repository`                              | Bonita image repository                                                           | `bonitasoft.jfrog.io/docker/bonita-subscription` |
| `image.tag`                                     | Bonita image tag                                                                  | `latest`                    |
| `image.pullPolicy`                              | Bonita image pull policy                                                          | `IfNotPresent`              |
| `image.pullSecrets`                             | Specify image pull secrets                                                        | `[]`                        |


### HTTP API parameters
| Name                                            | Description                                                                       | Default                     |
| ----------------------------------------------- | --------------------------------------------------------------------------------- | --------------------------- |
| `httpApi.enabled`                               | Enable exposing internal HTTP API                                                 | `""`                        |
| `httpApi.username`                              | Internal HTTP API Basic auth username                                             | `""`                        |
| `httpApi.password`                              | Internal HTTP API Basic auth password                                             | `""`                        |


### Serviceaccount parameters
| Name                                            | Description                                                                       | Default                     |
| ----------------------------------------------- | --------------------------------------------------------------------------------- | --------------------------- |
| `serviceAccount.create`                         | Create a serviceaccount                                                           | `false`                     |
| `serviceAccount.name`                           | Specify the name of the service account                                           | `default`                   |
| `serviceAccount.annotations`                    | Specify annotations for service account                                           | `{}`                        |

### Services parameters
| Name                                            | Description                                                                       | Default                     |
| ----------------------------------------------- | --------------------------------------------------------------------------------- | --------------------------- |
| `services.bonita.enabled`                       | Enable or disable `bonita` service                                                | `true`                      |
| `services.bonita.type`                          | Specify the `bonita` service type                                                 | `"ClusterIP"`               |
| `services.bonita.port`                          | Specify the `bonita` service port                                                 | `"8080"`                    |
| `services.hazlecast.enabled`                    | Enable or disable `hazlecast` service                                             | `true`                      |
| `services.hazlecast.type`                       | Specify the `hazlecast` service type                                              | `"ClusterIP"`               |
| `services.hazlecast.port`                       | Specify the `hazlecast` service port                                              | `"5701"`                    |

### Ingress parameters
| Name                                            | Description                                                                       | Default                     |
| ----------------------------------------------- | --------------------------------------------------------------------------------- | --------------------------- |
| `ingress.enabled`                               | If true, Bonita Ingress will be created                                           | `false`                      |
| `ingress.className`                             | Name of Priority Class to assign ingress                                          | `""`                        |
| `ingress.annotations`                           | Annotations to be added to the Bonita ingress                                     | `{}`                        |
| `ingress.hosts`                                 | Bonita Ingress hostnames                                                          | `[]`                        |
| `ingress.tls`                                   | Bonita Ingress TLS configuration                                                  | `{}`                        |

### Autoscaling parameters
| Name                                            | Description                                                                       | Default                     |
| ----------------------------------------------- | --------------------------------------------------------------------------------- | --------------------------- |
| `autoscaling.enabled`                           | If true, a horizontal pod autoscaler will be created                              | `false`                     |
| `autoscaling.minReplicas`                       | Minimum number of replicas for horizontal pod autoscaler                          | `1`                         |
| `autoscaling.maxReplicas`                       | Maximum number of replicas for horizontal pod autoscaler                          | `100`                       |
| `autoscaling.targetCPUUtilizationPercentage`    | Threshold of the average use of the CPU for horizontal pod autoscaler             | `80`                        |
| `autoscaling.targetMemoryUtilizationPercentage` | Threshold of the average use of the memory for horizontal pod autoscaler          | `""`                        |


### Credentials parameters
| Name                                            | Description                                                                       | Default                     |
| ----------------------------------------------- | --------------------------------------------------------------------------------- | --------------------------- |
| `credentials.tenant.username`                   | Username for the Bonita tenant administrator.                                  | `""`                        |
| `credentials.tenant.password`                   | Password for the Bonita tenant administrator                                      | `""`                        |
| `credentials.platform.username`                 | Username for the Bonita platform administrator                                 | `""`                        |
| `credentials.platform.password`                 | Password for the Bonita platform administrator                                    | `""`                        |
| `credentials.monitoring.username`                  | Basic auth username for monitoring endpoint                                       | `""`                        |
| `credentials.monitoring.password`               | Basic auth password for monitoring endpoint                                       | `""`                        |


### Datasources parameters
| Name                                            | Description                                                                       | Default                     |
| ----------------------------------------------- | --------------------------------------------------------------------------------- | --------------------------- |
| `datasources.bonita.vendor`                      | Bonita database vendor (possible values : h2, postgres, mysql)                    | `""`                        |
| `datasources.bonita.host`                        | Bonita database server host                                                       | `""`                        |
| `datasources.bonita.port`                        | Bonita database server port                                                       | `""`                        |
| `datasources.bonita.username`                        | Bonita database server username                                                       | `""`                        |
| `datasources.bonita.password`                    | Bonita database user password                                                     | `""`                        |
| `datasources.bonita.initialsize`                 | Bonita database initial number of connections                                     | `""`                        |
| `datasources.bonita.maxtotal`                    | Bonita database maximum number of connections                                     | `""`                        |
| `datasources.bonita.minidle`                     | Bonita database minimum number of always established idle connections             | `""`                        |
| `datasources.bonita.maxidle`                     | Bonita database maximum number of always established idle connections             | `""`                        |
| `datasources.bdm.vendor`                         | Business database vendor (possible values : h2, postgres, mysql)                  | `""`                        |
| `datasources.bdm.host`                           | Business database server host                                                     | `""`                        |
| `datasources.bdm.port`                           | Business database server port                                                     | `""`                        |
| `datasources.bdm.username`                           | Business database server username                                                     | `""`                        |
| `datasources.bdm.password`                       | Business database user password                                                   | `""`                        |
| `datasources.bdm.initialsize`                    | Business database initial number of connections                                   | `""`                        |
| `datasources.bdm.maxtotal`                       | Business database maximum number of connections                                   | `""`                        |
| `datasources.bdm.minidle`                        | Business database minimum number of always established idle connections           | `""`                        |
| `datasources.bdm.maxidle`                        | Business database maximum number of always established idle connections           | `""`                        |


### Usagemetrics parameters
| Name                                            | Description                                                                       | Default                     |
| ----------------------------------------------- | --------------------------------------------------------------------------------- | --------------------------- |
| `usagemetrics.enabled`                          | Enable sending pay-per-use data to a usage metrics server                         | `""`                        |
| `usagemetrics.subscriptionId`                   | Id of the subscription to send to the usage metrics server                        | `""`                        |
| `usagemetrics.runtimeId`                        | Id of the running to send to the usage metrics server                             | `""`                        |
| `usagemetrics.accountName`                      | Name of the account to send to the usage metrics server                           | `""`                        |
| `usagemetrics.connectionUrl`                    | URL of the usage metrics server                                                   | `""`                        |
| `usagemetrics.connectionTimeout`                | Timeout for the usage metrics requests                                            | `""`                        |
| `usagemetrics.connectionAuthentication`         | Basic auth base64 encoded username and password                                   | `""`                        |


## How to use parameters

Specify each parameter using the `--set key=value` argument to `helm install`. For example,

```console
$ helm install my-release . \
--set credentials.tenant.password=supertenantpassword \
--set credentials.platform.password=superadminpassword
```

The above command sets the tenant and platform passwords

> NOTE: Once this chart is deployed, it is not possible to change the application's access credentials, such as usernames or passwords, using Helm.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```console
$ helm install my-release . -f my-custom-values.yaml
```

> **Tip**: All defaults values are defined in [values.yaml](values.yaml)

## Configuration

### Secure installation

Before deploying, make sure you have replaced all sensitive information such as usernames and passwords into an [encrypted values.yaml](https://github.com/jkroepke/helm-secrets) file (or use [Hashicorp Vault](https://www.vaultproject.io/) to store the secrets)

```yaml
credentials:
  tenant:
    username: "my_custom_tenant_user"
    password: "my_custom_tenant_password"

  platform:
    username: "my_custom_platform_user"
    password: "my_custom_platform_password"
```

### Auto scaling

You can enable autoscaling by configuring it through the values.yaml file:

```yaml
autoscaling:
  enabled: true
  minReplicas: 5
  maxReplicas: 50
  targetCPUUtilizationPercentage: 80
```
