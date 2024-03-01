# noseyparker-action
---
## What it is?
---
Uses [praetorian-inc/noseyparker](https://github.com/praetorian-inc/noseyparker) to scan a repository for secrets.

## How to use it?
---
There are two primary ways to use noseyparker-action. You can use it as a standalone action to scan your repository for secrets on occasion, or you can use it to fail a pipeline when secrets are detected.

### Standalone Action
---
Add this github action to a workflow or create a new one. This will run the action and upload any selected reports as a workspace artifact which can be downloaded after the fact. See the [Github docs on workspace artifacts](https://docs.github.com/en/actions/using-workflows/storing-workflow-data-as-artifacts) for more details.
```
name: Noseyparker
on:workflow_dispatch:
jobs:
  noseyparker:
    runs-on: ubuntu-latest
    name: Noseyparker Scan
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          path: main
      - name: Nose, Parker
        id: noseyparker
        uses: bpsizemore/noseyparker-action@v1.0.0
        with:
          report-format-human: 'true'
          report-format-json: 'true'
          report-format-jsonl: 'false'
          report-format-sarif: 'false'
          fail-on-finding: 'false'
          scan-directory: 'main'
          report-name: 'report'
        # Upload report to workspace artifacts
      - name: Upload Report
        uses: actions/upload-artifact@v4
        with:
          name: workspace_artifacts
          path: ${{ github.workspace }}/reports/
```

### Failing a pipeline
---
You may also want to run noseyparker as part of a pipeline and have it fail the job. noseyparker-action returns an output `np_status_code` which will be set to 2 if any findings are detected. The following example shows how you can do that while still uploading reports to workspace artifacts for review.
```
name: Noseyparker
on:workflow_dispatch:
jobs:
  noseyparker:
    runs-on: ubuntu-latest
    name: Noseyparker Fail on Finding
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          path: main
      - name: Nose, Parker
        id: noseyparker
        continue-on-error: true
        uses: bpsizemore/noseyparker-action@v1.0.0
        with:
          report-format-human: 'true'
          report-format-json: 'true'
          report-format-jsonl: 'false'
          report-format-sarif: 'false'
          fail-on-finding: 'false'
          scan-directory: 'main'
          report-name: 'report'
          fail-on-finding: 'true'
        # Upload report to workspace artifacts
      - name: Upload Report
        uses: actions/upload-artifact@v4
        with:
          name: workspace_artifacts
          path: ${{ github.workspace }}/reports/
      - name: Fail on Noseyparker findings
        run: if ${{ steps.noseyparker.outputs.np_status_code == 2 }}; then exit 1; fi
```

You can further simplify this if you don't need or want to upload reports to the workspace artifacts with this example.
```
name: Noseyparker
on:workflow_dispatch:
jobs:
  noseyparker:
    runs-on: ubuntu-latest
    name: Noseyparker Fail on Finding
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          path: main
      - name: Nose, Parker
        id: noseyparker
        uses: bpsizemore/noseyparker-action@v1.0.0
        with:
          report-format-human: 'true'
          report-format-json: 'true'
          report-format-jsonl: 'false'
          report-format-sarif: 'false'
          fail-on-finding: 'false'
          scan-directory: 'main'
          report-name: 'report'
          fail-on-finding: 'true'

```