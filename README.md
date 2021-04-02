# ado_pipelines_example
example pipelines for deploying dbt via Azure DevOps pipelines

# Steps to Set Up

1. Commit the build directory here to your dbt project repo.
1. Create an Azure Active Directory App Registration (aka Service Principal aka AAD App)
2. Create an Azure Resource Manager Service Connection in Azure DevOps for the AAD App (Ours is called `ITSDETEAM`)
3. Follow the normal workflow to create a new Azure pipeline based on an existing YAML file in the repo. For the following pipelines, you'll need to make add some pipeline variables and make them secret:
   1. `gatekeeper.yml` (i.e. CI): `$(DEV_SERVER)` and `$(DEV_DB)`
   1. `prod.yml` (i.e. CD) `$(PROD_SERVER)` and `$(PROD_DB)`
4. make a branch policy for your `dev` or `UAT` branch so that all PRs require that the gatekeeper passes
5. change the trigger and schedules to fit your needs.