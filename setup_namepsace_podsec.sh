#!/usr/bin/env bash
#

NAMESPACE="$1"

echo "Setting Pods secuirty to privilged for $NAMESPACE namespace"
oc label namespace "$NAMESPACE" --overwrite   pod-security.kubernetes.io/enforce=privileged   pod-security.kubernetes.io/enforce-version=v1.24   pod-security.kubernetes.io/audit=privileged

