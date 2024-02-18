#!/bin/sh -l

echo "noseyparker-action startup..."
time=$(date)
echo "Current time: $time"

echo "The first 3 args are..."
echo $1
echo $2
echo $3

echo "Starting scan for ..."
noseyparker scan --datastore np.action --github-user $1
NP_STATUS_CODE=$?

echo "Scan complete. Status code: $NP_STATUS_CODE"

if [ $NP_STATUS_CODE -eq 0 ]
then
    NP_STATUS="success"
else
    NP_STATUS="failed"
fi

echo "Fetching summary and report..."

NP_SUMMARY=$(noseyparker summarize --datastore np.action)
NP_REPORT=$(noseyparker report --datastore np.action)

echo "Complete, exporting data."

echo "np_status_code=$NP_STATUS_CODE" >> $GITHUB_OUTPUT
echo "np_status=$NP_STATUS" >> $GITHUB_OUTPUT
echo "np_summary=$NP_SUMMARY" >> $GITHUB_OUTPUT
echo "np_report=$NP_REPORT" >> $GITHUB_OUTPUT
echo "time=$time" >> $GITHUB_OUTPUT