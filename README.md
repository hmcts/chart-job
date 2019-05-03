# chart-job

Helm chart repository for Kubernetes Jobs and Cron Jobs.

Currently for simplicity, we don't support parallelism and multiple jobs from same release.

## Example configuration

```yaml
image: hmctssandbox.azurecr.io/hmcts/plum-batch:latest
environment:
  TEST_VAR: test
  CONFIG_TEMPLATE: "{{ .Release.Name }}-config"
configmap:
  VAR_A: VALUE_A
  VAR_B: VALUE_B
keyVaults:
  "s2s":
    resourceGroup: rpe-service-auth-provider
    secrets:
      - microservicekey-rd-user-profile-api
global:
  job:
    kind: CronJob
  subscriptionId: "bf308a5c-0624-4334-8ff8-8dca9fd43783"
  tenantId: "531ff96d-0ae9-462a-8d2d-bec7c0b42082"
  environment: saat
schedule: "*/1 * * * *"
```

### Secrets
To add secrets such as passwords and service keys to the Job chart you can use the the secrets section.
The secrets section maps the secret to an environment variable in the container.
e.g :
```yaml
secrets: 
  CONNECTION_STRING:
      secretRef: some-secret-reference
      key: connectionString
      disabled: false
```
**Where:**
- **CONNECTION_STRING** is the environment variable to set to the value of the secret ( this has to be capitals and can contain numbers or "_" ).
- **secretRef** is the service instance ( as in the case of PaaS wrappers ) or reference to the secret volume. It supports templating in values.yaml . Example : secretRef: some-secret-reference-{{ .Release.Name }}
- **key** is the named secret in the secret reference.
- **disabled** is optional and used to disable setting this environment value. This can be used to override the behaviour of default chart secrets. 


## Configuration

The following table lists the configurable parameters of the Job chart and their default values.

| Parameter                  | Description                                | Default  |
| -------------------------- | ------------------------------------------ | ----- |
| `global.job.kind`          | Enumerated field to create a `CronJob` or `Job`     | `Job`     |
| `schedule`                 | Cron expression for scheduling cron job. As the name suggests, its applicable and mandatory only if kind is `CronJob`    | `nil`     |
| `backoffLimit`             | The number of retries before considering a Job as failed   | `6`     |
| `activeDeadlineSeconds`    | Once a Job reaches activeDeadlineSeconds, all of its Pods are terminated and the Job status will become type: Failed with reason: DeadlineExceeded    | `nil`     |
| `ttlSecondsAfterFinished`  | TTL to clean up finished Jobs, note this is an alpha feature currently and can be enabled with feature gate TTLAfterFinished | `nil`     |
| `releaseNameOverride`      | Will override the resource name - advised to use with pipeline variable SERVICE_NAME: `releaseNameOverride: ${SERVICE_NAME}-my-custom-name`      | `Release.Name-Chart.Name`     |
| `image`                    | Full image url | `nil` |
| `environment`              |  A map containing all environment values you wish to set. <br> **Note**: environment variables (the key in KEY: value) must be uppercase and only contain letters,  "_", or numbers and value can be templated | `nil`|
| `configmap`                | A config map, can be used for environment specific config.| `nil`|
| `memoryRequests`           | Requests for memory | `512Mi`|
| `cpuRequests`              | Requests for cpu | `25m`|
| `memoryLimits`             | Memory limits| `1024Mi`|
| `cpuLimits`                | CPU limits | `2500m`|
| `secrets`                  | Mappings of environment variables to service objects or pre-configured kubernetes secrets |  nil |
| `keyVaults`                | Mappings of keyvaults to be mounted as flexvolumes (see Example Configuration) |  nil |

## Adding Azure Key Vault Secrets
Key vault secrets can be mounted to the container filesystem using what's called a [keyvault-flexvolume](https://github.com/Azure/kubernetes-keyvault-flexvol). A flexvolume is just a kubernetes volume from the user point of view. This means that the keyvault secrets are accessible as files after they have been mounted.
To do this you need to add the **keyVaults** section to the configuration.
```yaml
keyVaults:
    <VAULT_NAME>:
      excludeEnvironmentSuffix: true
      resourceGroup: <VAULT_RESOURCE_GROUP>
      secrets:
        - <SECRET_NAME>
        - <SECRET_NAME2>
    <VAULT_NAME_2>:
      resourceGroup: <VAULT_RESOURCE_GROUP_2>
      secrets:
        - <SECRET_NAME>
        - <SECRET_NAME2>
```
**Where**:
- *<VAULT_NAME>*: Name of the vault to access without the environment tag i.e. `s2s` or `bulkscan`.
- *<VAULT_RESOURCE_GROUP>*: Resource group for the vault. This also does not need the environment tag (i.e. for s2s vault it is `rpe-service-auth-provider`).
- *<SECRET_NAME>* Secret name as it is in the vault. Note this is case and punctuation sensitive. i.e. in s2s there is the `microservicekey-cmcLegalFrontend` secret.
- *excludeEnvironmentSuffix*: This is used for the global key vaults where there is not environment suffix ( e.g `-aat` ) required. It defaults to false if it is not there and should only be added if you are using a global key-vault.

**Note**: to enable `keyVaults` to be mounted as flexvolumes, your service principal credentials need to be added to your namespace as a Kubernetes secret named `kvcreds` and accessible by the KeyVault FlexVolume driver. 

## Development and Testing

Default configuration (e.g. default image and ingress host) is setup for sandbox. This is suitable for local development and testing.

- Ensure you have logged in with `az cli` and are using `sandbox` subscription (use `az account show` to display the current one).
- For local development see the `Makefile` for available targets.
- To execute an end-to-end build, deploy and test run `make`.
- to clean up deployed releases, charts, test pods and local charts, run `make clean`

`helm test` will deploy a busybox container alongside the release which performs a simple HTTP request against the service health endpoint. If it doesn't return `HTTP 200` the test will fail. **NOTE:** it does NOT run with `--cleanup` so the test pod will be available for inspection.

## Azure DevOps Builds

Builds are run against the 'nonprod' AKS cluster.

### Pull Request Validation

A build is triggered when pull requests are created. This build will run `helm lint`, deploy the chart using `ci-values.yaml` and run `helm test`.

### Release Build

Triggered when the repository is tagged (e.g. when a release is created). Also performs linting and testing, and will publish the chart to ACR on success.
