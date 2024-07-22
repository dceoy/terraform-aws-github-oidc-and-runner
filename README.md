terraform-aws-github-oidc-and-runner
====================================

Terraform module for GitHub OIDC provider and Actions runner on AWS

[![CI](https://github.com/dceoy/terraform-aws-github-oidc-and-runner/actions/workflows/ci.yml/badge.svg)](https://github.com/dceoy/terraform-aws-github-oidc-and-runner/actions/workflows/ci.yml)

Installation
------------

1.  Check out the repository.

    ```sh
    $ git clone https://github.com/dceoy/terraform-aws-github-oidc-and-runner.git
    $ cd terraform-aws-github-oidc-and-runner
    ````

2.  Install [AWS CLI](https://aws.amazon.com/cli/) and set `~/.aws/config` and `~/.aws/credentials`.

3.  Install [Terraform](https://www.terraform.io/) and [Terragrunt](https://terragrunt.gruntwork.io/).

4.  Initialize Terraform working directories.

    ```sh
    $ terragrunt run-all init --terragrunt-working-dir='envs/dev/' -upgrade -reconfigure
    ```

5.  Generates a speculative execution plan. (Optional)

    ```sh
    $ terragrunt run-all plan --terragrunt-working-dir='envs/dev/'
    ```

6.  Creates or updates infrastructure.

    ```sh
    $ terragrunt run-all apply --terragrunt-working-dir='envs/dev/' --terragrunt-non-interactive
    ```

    If you connect to GitHub using OAuth, you need to re-run the above command after completing the authentication on the AWS Management Console.

7.  Update `runs-on` in GitHub Actions workflow YAML files.
    (Replace `<project-name>` with the CodeBuild project name.)

    ```yaml
    runs-on: codebuild-<project-name>-${{ github.run_id }}-${{ github.run_attempt }}
    ```

Cleanup
-------

```sh
$ terragrunt run-all destroy --terragrunt-working-dir='envs/dev/' --terragrunt-non-interactive
```
