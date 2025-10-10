#!/usr/bin/env bash

# Genera un template Helm chart riutilizzabile per vari progetti
# Usage: ./create-helm-template.sh myapp

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <chart-name>"
  exit 1
fi

CHART_NAME=$1
CHART_DIR="./$CHART_NAME"

echo "Creating Helm chart: $CHART_NAME"
mkdir -p "$CHART_DIR"/{charts,templates}

# Chart.yaml
cat > "$CHART_DIR/Chart.yaml" <<EOF
apiVersion: v2
name: $CHART_NAME
description: A Helm chart for deploying $CHART_NAME
type: application
version: 0.1.0
appVersion: "1.0.0"
EOF

# values.yaml
cat > "$CHART_DIR/values.yaml" <<EOF
replicaCount: 1

image:
  repository: myregistry.io/$CHART_NAME
  tag: latest
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80

resources: {}
EOF

# templates/deployment.yaml
cat > "$CHART_DIR/templates/deployment.yaml" <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "{{ .Chart.Name }}.fullname" . }}
  labels:
    app: {{ include "{{ .Chart.Name }}.name" . }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ include "{{ .Chart.Name }}.name" . }}
  template:
    metadata:
      labels:
        app: {{ include "{{ .Chart.Name }}.name" . }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          ports:
            - containerPort: 80
          resources: {{- toYaml .Values.resources | nindent 12 }}
EOF

# templates/service.yaml
cat > "$CHART_DIR/templates/service.yaml" <<'EOF'
apiVersion: v1
kind: Service
metadata:
  name: {{ include "{{ .Chart.Name }}.fullname" . }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: 80
  selector:
    app: {{ include "{{ .Chart.Name }}.name" . }}
EOF

# helpers
cat > "$CHART_DIR/templates/_helpers.tpl" <<'EOF'
{{/*
Expand the name of the chart.
*/}}
{{- define "{{ .Chart.Name }}.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "{{ .Chart.Name }}.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "{{ .Chart.Name }}.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}
EOF

echo "Helm chart template created in $CHART_DIR/"
