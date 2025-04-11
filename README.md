# deploy-action

This repo contains the GitHub Action that can be used to deploy Superblocks resources from a connected GitHub repo to Superblocks.

See the [Source Control documentation](https://docs.superblocks.com/development-lifecycle/source-control/) for more information.

## Description

<!-- AUTO-DOC-DESCRIPTION:START - Do not remove or modify this section -->

Deploy Applications, Workflows, and Scheduled Jobs in Superblocks

<!-- AUTO-DOC-DESCRIPTION:END -->

## Usage

```yaml
name: Deploy Applications, Workflows, and Scheduled Jobs in Superblocks
on: [deploy]

jobs:
  superblocks-deploy:
    runs-on: ubuntu-latest
    name: Deploy in Superblocks
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Deploy
        uses: superblocksteam/deploy-action@v1
        id: deploy
        with:
          token: ${{ secrets.SUPERBLOCKS_TOKEN }}
```

The above shows a standalone workflow. If you want to incorporate it as part of an existing workflow/job, simply copy the checkout and push steps into your workflow.

You can also pin to a [specific release version](https://github.com/superblocksteam/deploy-action/releases) in the format @v1.x.x.

### EU region

If your organization uses Superblocks EU, set the `domain` to `eu.superblocks.com` in the `Deploy` step.

```yaml
      ...

      - name: Deploy
        uses: superblocksteam/deploy-action@v1
        id: deploy
        with:
          token: ${{ secrets.SUPERBLOCKS_TOKEN }}
          domain: eu.superblocks.com
```

## Inputs

<!-- AUTO-DOC-INPUT:START - Do not remove or modify this section -->

| INPUT  |  TYPE  | REQUIRED |         DEFAULT         |                                                                 DESCRIPTION                                                                  |
|--------|--------|----------|-------------------------|----------------------------------------------------------------------------------------------------------------------------------------------|
| domain | string |  false   | `"app.superblocks.com"` |                                              The Superblocks domain where resources are hosted                                               |
|  path  | string |  false   |          `"."`          | The relative path from repo root to the Superblocks root directory. This is where the ~.superblocks/superblocks.json config file is located. |
|  sha   | string |  false   |        `"HEAD"`         |                                                          Commit to deploy changes for                                                          |
| token  | string |   true   |                         |                                                     The Superblocks access token to use                                                      |

<!-- AUTO-DOC-INPUT:END -->

## Outputs

<!-- AUTO-DOC-OUTPUT:START - Do not remove or modify this section -->
No outputs.
<!-- AUTO-DOC-OUTPUT:END -->
