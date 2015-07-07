# Production stock trading suggestions

## Pipeline
|script           | desc|
|-----------------|-----|
| `historical.pl` | grab a 20ish day snapshot of data|
| `screen.R`      | find stocks that look good       |
| `currentData.pl`| get current data on good stocks  |
| `cleanup.pl`    | scrub database                   |

## Data

data is stored in sqlite db with three tables.
