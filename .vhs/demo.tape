# VHS tape, scripted terminal demo of gtm-semantic-layer.
# Render: `vhs .vhs/demo.tape`. Outputs docs/img/demo.gif plus
# docs/img/mf-query-output.png and docs/img/skills-tree.png as screenshots.
# No human recording; re-render after any user-facing change.

Output docs/img/demo.gif

Set FontSize 15
Set Width 1240
Set Height 720
Set Theme "Dracula"
Set TypingSpeed 50ms
Set PlaybackSpeed 1.0

Type "# gtm-semantic-layer: dbt + MetricFlow + skills folder"
Sleep 800ms
Enter

Type "# 22 public metrics across 6 semantic models. Let's query one."
Sleep 1s
Enter
Enter

Type ".venv/bin/mf query --metrics arr --group-by metric_time__month --order metric_time__month 2>&1 | grep -E 'metric_time|20[0-9]{2}' | head -15"
Enter
Sleep 10s

Screenshot docs/img/mf-query-output.png

Enter
Type "# win_rate sliced by team x quarter"
Enter
Type ".venv/bin/mf query --metrics win_rate --group-by metric_time__quarter,opportunity__owner_team --order metric_time__quarter 2>&1 | grep -E 'metric_time|20[0-9]{2}|owner_team' | head -12"
Enter
Sleep 10s

Enter
Type "# Governance layer: markdown skills consumed by LLM assistants"
Enter
Type "tree skills -L 2"
Enter
Sleep 2s

Screenshot docs/img/skills-tree.png

Sleep 2s

Type "# Each skill has YAML frontmatter and 7 standard sections"
Enter
Type "head -14 skills/metrics/nrr.md"
Enter
Sleep 3s

Sleep 2s
