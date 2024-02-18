#!/bin/sh -l

echo "noseyparker-action startup..."
time=$(date)
echo "Current time: $time"

    - ${{ inputs.upload-reports }}
    - ${{ inputs.report-format-human }}
    - ${{ inputs.report-format-json }}
    - ${{ inputs.report-format-jsonl }}
    - ${{ inputs.report-format-sarif }}
    - ${{ inputs.github-username }}

NP_UPLOAD_REPORTS=$1
NP_REPORT_FORMAT_HUMAN=$2
NP_REPORT_FORMAT_JSON=$3
NP_REPORT_FORMAT_JSONL=$4
NP_REPORT_FORMAT_SARIF=$5
NP_GITHUB_USERNAME=$6

echo "Configuration: "
echo "UPLOAD_REPORTS: $NP_UPLOAD_REPORTS"
echo "REPORT_FORMAT_HUMAN: $NP_REPORT_FORMAT_HUMAN"
echo "REPORT_FORMAT_JSON: $NP_REPORT_FORMAT_JSON"
echo "REPORT_FORMAT_JSONL: $NP_REPORT_FORMAT_JSONL"
echo "REPORT_FORMAT_SARIF: $NP_REPORT_FORMAT_SARIF"
echo "GITHUB_USERNAME: $NP_GITHUB_USERNAME"

echo "Starting scan for $NP_GITHUB_USERNAME"
noseyparker scan --datastore np.action --github-user $NP_GITHUB_USERNAME
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
   if [[ $NP_REPORT_FORMAT_HUMAN == "true" ]]; then
      noseyparker report --datastore=np.action --format=human --output=/github/workspace/report.human
   fi
   
   if [[ $NP_REPORT_FORMAT_JSON == "true" ]]; then
      noseyparker report --datastore=np.action --format=json --output=/github/workspace/report.json
   fi
   
   if [[ $NP_REPORT_FORMAT_JSONL == "true" ]]; then
      noseyparker report --datastore=np.action --format=jsonl --output=/github/workspace/report.jsonl
   fi
   
   if [[ $NP_REPORT_FORMAT_SARIF == "true" ]]; then
      noseyparker report --datastore=np.action --format=sarif --output=/github/workspace/report.sarif
   fi
else
	echo "Skipping reports. Set upload-reports to 'true' in your actions file to run."
fi

NP_SUMMARY=$(noseyparker summarize --datastore np.action)
echo "Report summary..."
echo $NP_SUMMARY

echo "Action Complete - exporting data."

echo "np_status_code=$NP_STATUS_CODE" >> $GITHUB_OUTPUT
echo "np_status=$NP_STATUS" >> $GITHUB_OUTPUT
echo "time=$time" >> $GITHUB_OUTPUT