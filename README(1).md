
# SSRF Scanner - By Mon3m

![banner](https://img.shields.io/badge/BY-MON3M-blue?style=for-the-badge)

> Bash script to automate SSRF vulnerability detection via parameter fuzzing, built with creativity and efficiency.  
> Happy hacking! 🎯

---

## 📖 About

This tool automates the process of **finding SSRF (Server-Side Request Forgery)** vulnerabilities by fuzzing URL parameters with payloads commonly used to exploit SSRF.

It fetches historical URLs via **Waybackurls**, filters those with parameters, and injects various payloads to detect potential SSRF points based on HTTP responses.

---

## 🚀 Features

- 🔥 Automatically fetches URLs from Wayback Machine
- 🎯 Scans either all parameters or common ones (like `url`, `redirect`, `next`, etc.)
- ⚡ Supports adding your own custom blind server for detection
- 🤖 Auto mode for quick non-blind payloads
- 📂 Organized results stored in a `results/` directory
- 🛡️ Handles both single and bulk target scans

---

## 📦 Requirements

- **Linux / macOS / WSL**  
- `bash`
- `curl`
- [`waybackurls`](https://github.com/tomnomnom/waybackurls)

> Install `waybackurls` easily:  
> ```bash
> go install github.com/tomnomnom/waybackurls@latest
> ```

---

## 🛠️ Usage

```bash
chmod +x ssrf_scanner.sh
./ssrf_scanner.sh -u <url> | -l <file> [-a | -p] [-s <blind_server>] [--auto] [--server-only <url>]
```

### Options:

| Flag | Description |
|:---|:---|
| `-u <url>` | Scan a **single** target |
| `-l <file>` | Scan a **list** of targets from a file |
| `-a` | Scan **all** parameters |
| `-p` | Scan only **common** SSRF-related parameters |
| `-s <server_url>` | Add your own **blind server** URL to payloads |
| `--auto` | Use only **built-in non-blind payloads** |
| `--server-only <url>` | Use **only your server** as payload (blind testing only) |

---

## 🌿 Example Commands

**Scan a single target:**
```bash
./ssrf_scanner.sh -u https://example.com
```

**Scan a list of targets:**
```bash
./ssrf_scanner.sh -l targets.txt
```

**Scan all parameters with a custom server:**
```bash
./ssrf_scanner.sh -u https://example.com -a -s http://yourserver.com
```

**Use only server payloads (blind SSRF detection):**
```bash
./ssrf_scanner.sh -u https://example.com --server-only http://yourserver.com
```

---

## 🧪 How It Works

- Fetch URLs using `waybackurls`.
- Filter URLs with query parameters (`?param=value`).
- Inject SSRF payloads into each parameter.
- Detect based on response codes:
  - `500`, `502`, `408`, `504` = suspicious behavior.
- Log suspected URLs into the `results/` folder.

---

## 📁 Output

- All raw URLs → `results/<domain>-raw.txt`
- URLs with parameters → `results/<domain>-params.txt`
- Suspected SSRF endpoints → `results/<domain>-ssrf-log.txt`

---

## ⚡ TODO (Planned Features)

- [ ] Add multi-threading for faster scans
- [ ] Detect SSRF through DNS interaction (burp collaborator, interactsh, etc.)
- [ ] Smarter response analysis (content length, redirects)

---

## 🧠 Author

- **Name:** Mon3m
- **Title:** Bug Hunter, Ethical Hacker, Pentester
- **Connect:** [LinkedIn](#) | [Twitter](#)

---

## ⚠️ Disclaimer

This tool is intended **ONLY** for educational purposes and authorized security testing.  
Unauthorized use against systems without permission is illegal and unethical.
