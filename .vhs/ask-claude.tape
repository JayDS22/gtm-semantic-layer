# VHS tape: the ask-Claude pattern end-to-end.
# A GTM question in plain English -> Claude reads the right skill card ->
# emits a deterministic MetricFlow query -> returns real tabular output.
# Render with `vhs .vhs/ask-claude.tape`. No human recording.

Output docs/img/ask-claude-demo.gif

Set FontSize 15
Set Width 1280
Set Height 760
Set Theme "Monokai Pro"
Set Padding 20

Type "# A plain-English GTM question routed via the skills/ folder."
Enter
Sleep 1500ms

Type "./scripts/ask_claude.py 'show ARR trending by month' --run"
Enter
Sleep 6s

Type "clear"
Enter
Sleep 500ms

Type "# Second question: cohort-sliced NRR. Watch the group-by get added."
Enter
Sleep 1500ms

Type "./scripts/ask_claude.py 'show NRR by cohort monthly' --run"
Enter
Sleep 6s

Type "clear"
Enter
Sleep 500ms

Type "# Third: Rule-of-40 at quarter grain. Different skill, same contract."
Enter
Sleep 1500ms

Type "./scripts/ask_claude.py 'rule of 40 by quarter' --run"
Enter
Sleep 6s

Type "clear"
Enter
Sleep 500ms

Type "# The pattern: 23 skill cards, 1 deterministic contract."
Enter
Type "# No hallucinated SQL. Every answer traces to a frontmatter-tagged metric."
Enter
Sleep 4s
