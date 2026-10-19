{{- $teams := where hugo.Data.teams "active" true -}}
{{- $slug := lower (path.Base .File.Dir) -}}
{{ replaceRE `.*week-0*([0-9]+)$` "${1}주차 수업 기록" $slug }}

(핵심 3~4줄. 이번 주 주제와 수업에서 있었던 일을 팀 구분 없이 짧게 쓴다. 이 괄호 줄은 지운다.)

[대표 이미지: 파일명 — 네이버 에디터에서 직접 업로드]
{{ range $teams }}
{{ .emoji }} {{ .name }} 연구원들의 한마디
「{{ .name }} 연구원 A」:
{{ end }}
전체 기록 보기 → {{ site.BaseURL }}posts/{{ $slug }}/
