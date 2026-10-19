{{- $teams := where hugo.Data.teams "active" true -}}
---
title: "{{ replaceRE `.*week-0*([0-9]+)$` "${1}주차 수업 기록" .File.ContentBaseName }}"
date: {{ .Date }}
draft: true
tags: []
teams: [{{ range $i, $t := $teams }}{{ if $i }}, {{ end }}"{{ $t.name }}"{{ end }}]
summary: ""
cover:
  image: ""
  alt: ""
---

## 이번 주 주제

## 오늘의 수업 흐름
{{ range $teams }}
## {{ .emoji }} {{ .name }}

### 연구원들이 만든 것

### 연구원들의 한마디

> 「{{ .name }} 연구원 A」:
{{ end }}
## 다음 주 예고
