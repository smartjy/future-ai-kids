{{- $teams := where hugo.Data.teams "active" true -}}
---
title: "{{ replaceRE `.*week-0*([0-9]+)$` "${1}주차 수업 기록" .File.ContentBaseName }}"
date: {{ .Date }}
draft: true
tags: []
teams: [{{ range $i, $t := $teams }}{{ if $i }}, {{ end }}"{{ $t.name }}"{{ end }}]
summary: ""
# 팀마다 이번 주에 만든 것 한 줄 (홈 화면 기록판에 나온다). 쉰 팀은 지운다.
made:
{{- range $teams }}
  {{ .name }}: ""
{{- end }}
cover:
  image: ""
  alt: ""
---

<!--
영상 넣는 법: 글 폴더에 파일을 두고, 아래 줄을 주석 밖 본문으로 옮긴 뒤 /* 와 */ 를 지운다.
{{ `{{</* clip src="app-demo.mp4" alt="퀴즈 앱이 점수를 올리는 장면" */>}}` }}
4초 이하는 gif, 그보다 길면 mp4로 만든다.
-->

## (이번 주 주제를 그대로 제목으로 — 예: AI 시대, 나는 어떤 일을 하게 될까?)

## 오늘의 수업 흐름
{{ range $teams }}
## {{ .emoji }} {{ .name }}

### 아이들이 만든 것

### 아이들의 한마디

<!-- 메모에 아이가 한 말이 없으면 이 칸째 지운다 -->
> 「○○○」:
{{ end }}
## 숙제

<!-- 메모에 숙제가 없으면 이 섹션째 지운다 -->

## 다음 주 예고

<!-- 메모에 예고가 없으면 이 섹션째 지운다 -->
