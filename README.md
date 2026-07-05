# kaggle-download

A small bash script that batch-downloads Kaggle datasets, one slug per line.
Each dataset is unzipped into its own subdirectory under `DOWNLOAD_DIR`.

## Prerequisites

- Python 3.8+
- A Kaggle account and API credentials (see [Setup](#setup))

## Setup

1. **Clone the repo:**

   ```bash
   git clone git@github.com:mesbahworld/kaggle-download.git
   cd kaggle-download
   ```

2. **Create your `.env` from the template:**

   ```bash
   cp .env.example .env
   ```

   Then edit `.env` and fill in your credentials:

   - `KAGGLE_USERNAME` and `KAGGLE_KEY` — get them from
     <https://www.kaggle.com/settings> → *Create New API Token* (downloads a
     `kaggle.json` whose `username` and `key` fields go here).
   - *or* `KAGGLE_API_TOKEN` — a `KGAT_...` token, if you prefer token auth.
   - `DOWNLOAD_DIR` — where datasets land. Relative paths are resolved
     against the project root; defaults to `./data`.

   Only one of the credential options is needed. You can also keep credentials
   in `~/.kaggle/kaggle.json` or `~/.kaggle/access_token` (chmod 600) and skip
   the `.env` entries entirely — the script checks those locations too.

3. **Run the downloader.** On first run it will create `.venv/`, install the
   `kaggle` package, then proceed to download:

   ```bash
   ./download.sh
   ```

## Usage

List the dataset slugs you want in `datasets.txt` (one per line, in the form
`owner/dataset-name`):

```
warcoder/bangla-text-detection-and-recognition
heptapod/titanic
```

Then run:

```bash
./download.sh                     # downloads every slug in datasets.txt
./download.sh owner/dataset-name  # downloads just the one(s) you pass
```

Lines starting with `#` and blank lines in `datasets.txt` are ignored.

Files are saved to `$DOWNLOAD_DIR` (default `./data/`):

```
data/
├── bangla-text-detection-and-recognition/
│   └── ...
└── titanic/
    └── ...
```

## Project layout

```
kaggle-download/
├── .env.example      # template for credentials & config
├── .gitignore
├── README.md
├── datasets.txt      # list of Kaggle dataset slugs to download
├── download.sh       # the downloader (auto-bootstraps .venv/ on first run)
└── .venv/            # created automatically, gitignored
```

## Troubleshooting

- **"python3 not found in PATH"** — install Python 3.8+ (e.g. `brew install
  python`).
- **Bootstrap hangs or fails on `pip install kaggle`** — usually a network
  issue. Run `./download.sh` again; the venv is reused once created.
- **"no Kaggle credentials"** — `.env` is missing or the keys are still the
  placeholders. Double-check the file and the values.
- **403 / 401 errors** — your token is invalid or expired; regenerate it from
  <https://www.kaggle.com/settings>.
- **Permission denied on `download.sh`** — run `chmod +x download.sh`.

## License

MIT.
