# ado_pipelines_example
example pipelines for deploying dbt via Azure DevOps pipelines

## Overview

### Azure CLI  task
Check out the `.yml` files in the [`build/` dir](build/) for our pipelines.

Once you have an ADO ARM Service Connection that has owner permission on the db, the work is done. With the `AzureCLI` task and the `azureSubscription` param, you never have to call `az login`, it will do that for you automatically.

To make the secret pipeline variables available to the task, you have to map them with the `env` dict shown below.

```yaml
- task: AzureCLI@2
  displayName: 'dbt run'
  inputs:
    azureSubscription: ITSDETEAM
    ScriptType: bash
    scriptLocation: inlineScript
    inlineScript: |
      dbt run --profiles-dir $(location)
  env:
    HOST: $(host)
    DB: $(db)
```

### profile tweaks

To avoid uploading a secure file containing our [`build/profiles.yml`](build/profiles.yml), we just added three environment variable references to the only target. This allows us to just set the server and db within the Azure Pipeline itself.


```yaml
jaffle_shop:
  target: default
  outputs:
    default:
      type: sqlserver # or synapse or whatever you want
      driver: "ODBC Driver 17 for SQL Server"
      schema: "{{ env_var('SCHEMA') }}"
      host: "{{ env_var('HOST') }}"
      database: "{{ env_var('DB') }}"
      authentication: CLI
      port: 1433
```

## Steps to Set Up

1. Commit the build directory here to your dbt project repo.
1. Create an Azure Active Directory App Registration (aka Service Principal aka AAD App)
2. Set the Azure Active Directory Admin on the Azure SQL/Synapse db to be either you or a DL that contains you.
3. Log into db with AAD admin creds and add the App Registration as an owner on your dev and prod db's
    ```sql
    CREATE USER [my_service_connection] FROM EXTERNAL PROVIDER
    exec sp_addrolemember 'db_owner', 'my_service_connection'
    ```
4. Create an Azure Resource Manager Service Connection in Azure DevOps for the AAD App (Ours is called `ITSDETEAM`)
5. Follow the normal workflow to create a new Azure pipeline based on an existing YAML file in the repo. For the following pipelines, you'll need to make add some [secret pipeline variables](https://i.stack.imgur.com/3WBDC.png) :
   1. `gatekeeper.yml` (i.e. CI): `$(DEV_SERVER)` and `$(DEV_DB)`
   2. `prod.yml` (i.e. CD) `$(PROD_SERVER)` and `$(PROD_DB)`
6. make a branch policy for your `dev` or `UAT` branch so that all PRs require that the gatekeeper passes
7. change the trigger and schedules to fit your needs.