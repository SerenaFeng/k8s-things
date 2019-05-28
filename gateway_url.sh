#!/bin/bash

svc=${1}; shift
ns=${1}; shift
pod_selector="$@"

echo "get gateway information of svc [${svc}] under the namespace [${ns}], which the pod selector [${pod_selector}]"

ingw=$(kubectl get svc ${svc} -n ${ns} | tail -1 | awk '{print $4}')

schema="https"
[[ $ingw =~ (pending|none) ]] && {
  ingress_port=$(kubectl -n ${ns} get service ${svc} -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
  [[ "${ingress_port}x" == "x"  ]] && {
     ingress_port=$(kubectl -n ${ns} get service ${svc} -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
     schema="http"
  }
  ingress_host=$(kubectl get po ${pod_selector} -n ${ns} -o 'jsonpath={.items[0].status.hostIP}')
} || {
  ingress_host=$(kubectl -n ${ns} get service ${svc} -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  ingress_port=$(kubectl -n ${ns} get service ${svc} -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
  [[ "${ingress_port}x" == "x"  ]] && {
    ingress_port=$(kubectl -n ${ns} get service ${svc} -o jsonpath='{.spec.ports[?(@.name=="http")].port}')
    schema="http"
  }
}

export GATEWAY_URL=${schema}://${ingress_host}:${ingress_port}

echo "ingress_host=${ingress_host}"
echo "ingress_port=${ingress_port}"
echo "GATEWAY_URL=${GATEWAY_URL}"
