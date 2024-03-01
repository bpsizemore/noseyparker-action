#!/bin/bash -l

echo "noseyparker-action startup..."
time=$(date)
echo "Current time: $time"

NP_UPLOAD_REPORTS=$1
NP_REPORT_NAME=$2
NP_REPORT_FORMAT_HUMAN=$3
NP_REPORT_FORMAT_JSON=$4
NP_REPORT_FORMAT_JSONL=$5
NP_REPORT_FORMAT_SARIF=$6
NP_REPO_URL=$7
NP_FAIL_ON_FINDING=$8

NP_DATASTORE="np.action"

echo "Configuration: "
echo "UPLOAD_REPORTS: $NP_UPLOAD_REPORTS"
echo "REPORT_FORMAT_HUMAN: $NP_REPORT_FORMAT_HUMAN"
echo "REPORT_FORMAT_JSON: $NP_REPORT_FORMAT_JSON"
echo "REPORT_FORMAT_JSONL: $NP_REPORT_FORMAT_JSONL"
echo "REPORT_FORMAT_SARIF: $NP_REPORT_FORMAT_SARIF"

echo "Starting scan for local repository"

# test
ls
ls ./main

noseyparker scan --datastore $NP_DATASTORE $NP_REPO_URL
NP_STATUS_CODE=$?

echo "Scan complete. Status code: $NP_STATUS_CODE"

if [ $NP_STATUS_CODE -eq 0 ]
then
    NP_STATUS="success"
else
   # Scan failed - exit early
    NP_STATUS="failed"
    exit 1
fi



if [[ $NP_UPLOAD_REPORTS == "true" ]]; then
   mkdir -p $GITHUB_WORKSPACE/reports

   if [[ $NP_REPORT_FORMAT_HUMAN == "true" ]]; then
      noseyparker report --datastore=$NP_DATASTORE --format=human --output="$GITHUB_WORKSPACE/reports/${NP_REPORT_NAME}.txt"
   fi
   
   if [[ $NP_REPORT_FORMAT_JSON == "true" ]]; then
      noseyparker report --datastore=$NP_DATASTORE --format=json --output="$GITHUB_WORKSPACE/reports/${NP_REPORT_NAME}.json"
   fi
   
   if [[ $NP_REPORT_FORMAT_JSONL == "true" ]]; then
      noseyparker report --datastore=$NP_DATASTORE --format=jsonl --output="$GITHUB_WORKSPACE/reports/${NP_REPORT_NAME}.jsonl"
   fi
   
   if [[ $NP_REPORT_FORMAT_SARIF == "true" ]]; then
      noseyparker report --datastore=$NP_DATASTORE --format=sarif --output="$GITHUB_WORKSPACE/reports/${NP_REPORT_NAME}.sarif"
   fi
else
   echo "Skipping reports. Set upload-reports to 'true' in your actions file to run."
fi

if [[ $NP_FAIL_ON_FINDING == "true" ]]; then
   FINDINGS=$(noseyparker report --format=json --datastore=$NP_DATASTORE | jq 'any(.[]; .type == "finding")')
   if [[ $FINDINGS == "true" ]]; then
      echo "Findings detected. Failing action..."
      echo "np_status_code=2" >> $GITHUB_OUTPUT
      exit 2
   else
      echo "No findings detected. Passing action..."
   fi
fi

NP_SUMMARY=$(noseyparker summarize --datastore $NP_DATASTORE)
echo "Report summary..."
echo $NP_SUMMARY

echo "Action Complete - exporting data."

echo "np_status_code=$NP_STATUS_CODE" >> $GITHUB_OUTPUT
echo "np_status=$NP_STATUS" >> $GITHUB_OUTPUT
echo "time=$time" >> $GITHUB_OUTPUT