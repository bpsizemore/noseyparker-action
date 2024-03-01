#!/bin/bash -l

echo "noseyparker-action startup..."
time=$(date)
echo "Current time: $time"

NP_LOCAL_OUTPUT=$1
NP_REPORT_NAME=$2
NP_REPORT_FORMAT_HUMAN=$3
NP_REPORT_FORMAT_JSON=$4
NP_REPORT_FORMAT_JSONL=$5
NP_REPORT_FORMAT_SARIF=$6
NP_SCAN_DIR=$7
NP_FAIL_ON_FINDING=$8
NP_SCAN_ARGS=$9

NP_DATASTORE="np.action"

echo "Configuration: "
echo "LOCAL_OUTPUT: $NP_LOCAL_OUTPUT"
echo "SCAN_DIR: $NP_SCAN_DIR"
echo "FAIL_ON_FINDING: $NP_FAIL_ON_FINDING"
echo "SCAN_ARGS: $NP_SCAN_ARGS"
echo "REPORT_FORMAT_HUMAN: $NP_REPORT_FORMAT_HUMAN"
echo "REPORT_FORMAT_JSON: $NP_REPORT_FORMAT_JSON"
echo "REPORT_FORMAT_JSONL: $NP_REPORT_FORMAT_JSONL"
echo "REPORT_FORMAT_SARIF: $NP_REPORT_FORMAT_SARIF"


echo "Scan command will look like..."
echo "noseyparker scan --datastore $NP_DATASTORE $NP_SCAN_DIR $NP_SCAN_ARGS"

eval "noseyparker scan --datastore $NP_DATASTORE $NP_SCAN_DIR $NP_SCAN_ARGS"
NP_STATUS_CODE=$?

echo "Scan complete. Status code: $NP_STATUS_CODE"

if [ $NP_STATUS_CODE -eq 0 ];
then
   NP_STATUS="success"
else
  # Scan failed - exit early
  echo "np_status_code=2" >> $GITHUB_OUTPUT
  echo "np_status=failed" >> $GITHUB_OUTPUT
  exit 1
fi

mkdir -p $GITHUB_WORKSPACE/reports

# This report is used for local output
if [[ $NP_LOCAL_OUTPUT == "true" ]] || [[ $NP_REPORT_FORMAT_HUMAN == "true" ]]; then
  noseyparker report --datastore=$NP_DATASTORE --format=human --output="$GITHUB_WORKSPACE/reports/${NP_REPORT_NAME}.txt"
fi

# This report is used for fail on finding
if [[ $NP_FAIL_ON_FINDING == "true" ]] || [[ $NP_REPORT_FORMAT_JSON == "true" ]]; then
  noseyparker report --datastore=$NP_DATASTORE --format=json --output="$GITHUB_WORKSPACE/reports/${NP_REPORT_NAME}.json"
fi

if [[ $NP_REPORT_FORMAT_JSONL == "true" ]]; then
  noseyparker report --datastore=$NP_DATASTORE --format=jsonl --output="$GITHUB_WORKSPACE/reports/${NP_REPORT_NAME}.jsonl"
fi

if [[ $NP_REPORT_FORMAT_SARIF == "true" ]]; then
  noseyparker report --datastore=$NP_DATASTORE --format=sarif --output="$GITHUB_WORKSPACE/reports/${NP_REPORT_NAME}.sarif"
fi
# Done scanning, now handle outputs and status
NP_SUMMARY=$(noseyparker summarize --datastore $NP_DATASTORE)
echo "Report summary..."
echo $NP_SUMMARY
echo ""


if [[ $NP_LOCAL_OUTPUT == "true" ]]; then
  echo "Printing human readable report..."
  cat $GITHUB_WORKSPACE/reports/${NP_REPORT_NAME}.txt
  echo ""
fi

if [[ $NP_FAIL_ON_FINDING == "true" ]]; then
  FINDINGS=$(cat $GITHUB_WORKSPACE/reports/${NP_REPORT_NAME}.json | jq 'any(.[]; .type == "finding")')
  if [[ $FINDINGS == "true" ]]; then
    echo "Findings detected. Failing action..."
    echo "np_status_code=2" >> $GITHUB_OUTPUT
    echo "np_status=failed" >> $GITHUB_OUTPUT
    exit 2
  else
    echo "No findings detected. Passing action..."
  fi
fi

echo "Action Complete - exporting data."

echo "np_status_code=$NP_STATUS_CODE" >> $GITHUB_OUTPUT
echo "np_status=$NP_STATUS" >> $GITHUB_OUTPUT
echo "time=$time" >> $GITHUB_OUTPUT
exit 0