# noseyparker-action
---
## What it is?
---
Uses [praetorian-inc/noseyparker](https://github.com/praetorian-inc/noseyparker) to scan a repository for secrets.

## How to use it?
---
Below are some example workflows that make use of noseyparker-action

### Standalone Action
---
This is the simplest workflow that will run noseyparker on each push and fail to alert if there are any findings. You can review the action output for the human readable report.
```
name: Noseyparker
on: push
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
          fail-on-finding: 'true'
```

### Upload reports to workspace artifacts on failure
---
noseyparker-action will use `exit 2` if there are findings and `fail-on-finding` is set to true. See the [Github docs on workspace artifacts](https://docs.github.com/en/actions/using-workflows/storing-workflow-data-as-artifacts) for more details.

```
name: Noseyparker
on: push
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
        continue-on-error: true
        uses: bpsizemore/noseyparker-action@v1.0.0
        with:
          fail-on-finding: 'true'
      - name: Upload Report
        uses: actions/upload-artifact@v4
        with:
          name: workspace_artifacts
          path: ${{ github.workspace }}/reports/
      - name: Fail on Noseyparker findings
        run: if ${{ steps.noseyparker.outputs.np_status_code == 2 }}; then exit 1; fi
```

### Additional report exports
---
You can specify additional report output formats.
```
name: Noseyparker
on: push
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
        continue-on-error: true
        uses: bpsizemore/noseyparker-action@v1.0.0
        with:
          fail-on-finding: 'true'
          report-format-human: 'true'
          report-format-json: 'true'
          report-format-jsonl: 'true'
          report-format-sarif: 'true'
      - name: Upload Report
        uses: actions/upload-artifact@v4
        with:
          name: workspace_artifacts
          path: ${{ github.workspace }}/reports/
      - name: Fail on Noseyparker findings
        run: if ${{ steps.noseyparker.outputs.np_status_code == 2 }}; then exit 1; fi
```

### Custom Arguments
---
Use the `scan-args` argument to pass in any additional arguments to the scan command. You could use this alongside files within your repo to add custom rules, scan an entire github org, target a remote repository or any other functionality provided by noseyparker's scan function.
```
name: Noseyparker
on: push
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
          fail-on-finding: 'true'
          scan-args: '--ruleset default --rules /main/np.rules/ --other-args'
        # Upload report to workspace artifacts
      - name: Upload Report
        uses: actions/upload-artifact@v4
        with:
          name: workspace_artifacts
          path: ${{ github.workspace }}/reports/
      - name: Fail on Noseyparker findings
        run: if ${{ steps.noseyparker.outputs.np_status_code == 2 }}; then exit 1; fi
```
