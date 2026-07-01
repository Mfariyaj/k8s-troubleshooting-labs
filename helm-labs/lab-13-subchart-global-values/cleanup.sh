#!/bin/bash
echo "Cleaning up Lab 13..."
helm uninstall myrelease --namespace lab13-subcharts 2>/dev/null || true
kubectl delete namespace lab13-subcharts 2>/dev/null || true
rm -f parentchart/charts/*.tgz parentchart/Chart.lock
echo "Cleanup complete."
