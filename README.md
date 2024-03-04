# noseyparker-action
---
## What it is?
---
Uses [praetorian-inc/noseyparker](https://github.com/praetorian-inc/noseyparker) to scan a repository for secrets.

## How to use it?
---
Below are some example workflows that make use of noseyparker-action

**Note:** It is highly recommended to create and use a custom ruleset when integrating noseyparker into your CI/CD pipeline. Excessive noise and false positives will not help improve security! See the section below on custom rulesets.

### Simple Example
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
        uses: bpsizemore/noseyparker-action@v0.0.16
        with:
          fail-on-finding: 'true'
```



### Custom Rulesets and Arguments
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
        uses: bpsizemore/noseyparker-action@v0.0.16
        with:
          fail-on-finding: 'true'
          scan-args: '--ruleset custom-ruleset --rules ./main/np.rules'
        # Upload report to workspace artifacts
      - name: Upload Report
        uses: actions/upload-artifact@v4
        with:
          name: workspace_artifacts
          path: ${{ github.workspace }}/reports/
      - name: Fail on Noseyparker findings
        run: if ${{ steps.noseyparker.outputs.np_status_code == 2 }}; then exit 1; fi
```

The example above uses a custom rules file in your repository. Look at `sample-rule.yaml` to see what a valid ruleset looks like and feel free to copy it into your repository as a starting point. 

In order to prevent false positives, you'll want to either create custom rules that target secrets specific to your repositories, or slowly enable rules as you resolve them to prevent a regression in the future.

### All Parameters
---
```
  local-output:
    description: 'echo human-readable findings to console'
    required: false
    default: 'true'
  report-name:
    description: 'File name for the reports without the extension'
    required: false
    default: 'report'
  report-format-human:
    description: 'upload human readable (txt) formatted report'
    required: false
    default: 'false'
  report-format-json:
    description: 'upload json formatted report'
    required: false
    default: 'false'
  report-format-jsonl:
    description: 'upload jsonl formatted report'
    required: false
    default: 'false'
  report-format-sarif:
    description: 'upload sarif formatted report'
    required: false
    default: 'false'
  scan-directory:
    description: 'relative directory of the repo to scan from $GITHUB_WORKSPACE'
    required: false
    default: 'main'
  fail-on-finding:
    description: 'set to true to interrupt the pipeline if there are any findings'
    required: false
    default: 'false'
  scan-args:
    description: 'Arguments to pass to scan - this is passed after datastore and scan-directory are specified. Arguments like --github-user will override the scan directory for local scanning.'
    required: false
    default: ''
```

## Other Examples

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
        uses: bpsizemore/noseyparker-action@v0.0.16
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
        uses: bpsizemore/noseyparker-action@v0.0.16
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