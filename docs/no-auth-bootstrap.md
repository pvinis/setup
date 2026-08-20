# Can a coding agent run with no auth at all? — investigation

Research for [#16](https://github.com/pvinis/setup/issues/16). The motivation is a chicken-and-egg
noted when [the bootstrap ticket](https://github.com/pvinis/setup/issues/9) closed: the agent needs
a login, the login lives in 1Password, and on macOS installing the 1Password app/CLI needs `brew`,
which needs Xcode Command Line Tools, which the agent was supposed to install. If an agent could run
with *no* credentials it could break that chain by installing 1Password, CLT and brew first.

**Verdict up front: no, don't do it for the desktop case.** The browser login it replaces costs about
a minute. The no-auth path costs ~4.8 GB of download and, when it finally works, takes five and a
half minutes to read a twelve-byte file. There is one case where the argument is even coherent, and
it is not the one the ticket was aimed at — see [The one exception](#the-one-exception) at the end.

Everything marked **verified** below was run on `hookers-green` (Omarchy 4.0.0, i7-9750H, 15 GiB RAM,
RTX 2070 Max-Q with 7.6 GiB VRAM) on 2026-08-20. Everything else is cited to a primary source.

## 1. Local models

### The runtimes, and what they actually cost to install

Two candidates. Their install stories are very different, and the difference matters more than the
model choice does.

**Ollama.** Official install is `curl -fsSL https://ollama.com/install.sh | sh` on both Linux and
macOS ([ollama/README.md](https://github.com/ollama/ollama/blob/main/README.md)); macOS also has a
drag-and-drop `.dmg` and requires "MacOS Sonoma (v14) or newer" on "Apple M series (CPU and GPU
support) or x86 (CPU only)" ([docs.ollama.com/macos](https://docs.ollama.com/macos.md)). Release
asset sizes, read from the GitHub API for `v0.32.15`
([ollama releases](https://github.com/ollama/ollama/releases)):

| asset | bytes | |
| --- | --- | --- |
| `ollama-darwin.tgz` (CLI only) | 154,052,856 | 154 MB |
| `Ollama.dmg` (app) | 188,996,695 | 189 MB |
| `ollama-linux-amd64.tar.zst` | 1,422,416,084 | **1.42 GB** |
| `ollama-linux-arm64.tar.zst` | 1,543,177,713 | 1.54 GB |

The Linux tarball is enormous because it bundles the CUDA runtime. Distro packaging splits that out
into separate accelerator packages — Arch's base `extra/ollama` is 17.3 MB compressed / 69.3 MB
installed, `extra/ollama-vulkan` is 7.2 MB / 55.3 MB, and `extra/ollama-cuda` is 759.6 MB / 1035.8 MB
([archlinux.org package search API](https://archlinux.org/packages/search/json/?q=ollama)). But
`pacman` needs `sudo`, and the point of this exercise is a path that works before anything is set up.

**Verified:** the sudo-free path is mise, which Omarchy already ships and which
[#9](https://github.com/pvinis/setup/issues/9) already picked for macOS. `mise registry ollama`
resolves to `aqua:ollama/ollama`, and the
[aqua registry entry](https://github.com/aquaproj/aqua-registry/blob/main/pkgs/ollama/ollama/registry.yaml)
downloads `ollama-darwin.tgz` on macOS and `ollama-linux-{arch}.tar.zst` on Linux — prebuilt binaries,
no compiler. `mise install ollama@latest` on this machine downloaded the 1.42 GB Linux tarball and
left **2.1 GB** in `~/.local/share/mise/installs/ollama/0.32.14`. No sudo, no CLT, no brew. On a bare
Mac the same command would pull the 154 MB darwin tarball instead.

**llama.cpp** is a tenth the size but has no comparable install path. The
[official install doc](https://github.com/ggml-org/llama.cpp/blob/master/docs/install.md) lists only
`brew install llama.cpp`, `nix profile install nixpkgs#llama-cpp`, `winget` and conda — and on a bare
Mac, `brew` is precisely the thing we can't have yet, since Homebrew's own
[installation docs](https://docs.brew.sh/Installation) require "Command Line Tools (CLT) for Xcode".
On Arch it is not in the official repos at all; only AUR (`llama.cpp-cuda`, `llama.cpp-vulkan`,
`llama.cpp-git` — verified via the [AUR RPC](https://aur.archlinux.org/rpc/v5/search/llama.cpp)),
which means `yay` and a build. That leaves grabbing a release tarball by hand, which is genuinely
tiny — from the [b10517 release](https://github.com/ggml-org/llama.cpp/releases):
`llama-b10517-bin-macos-arm64.tar.gz` is 11,090,071 bytes (11.1 MB),
`llama-b10517-bin-ubuntu-x64.tar.gz` is 16,667,382 bytes (16.7 MB), and the Vulkan Linux build is
33,286,902 bytes (33.3 MB). There is no prebuilt Linux CUDA build. `llama-server` does speak
OpenAI-compatible chat completions with tools, but its
[README](https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md) warns that
"OpenAI-style function calling is supported with the `--jinja` flag (and may require a
`--chat-template-file` override to get the right tool-use compatible Jinja template)". That is a
config cliff to fall off on a machine you're setting up for the first time.

So: **Ollama for a bootstrap, despite being 100× bigger**, because it is the only one with a
sudo-free, compiler-free, one-command install on both platforms.

### The weights

Sizes from the Ollama library pages, which also carry the `tools` capability tag:

| model | download | context on the card |
| --- | --- | --- |
| [`qwen3:0.6b`](https://ollama.com/library/qwen3) | 523 MB | 40K |
| [`qwen3:1.7b`](https://ollama.com/library/qwen3) | 1.4 GB | 40K |
| [`qwen3:4b`](https://ollama.com/library/qwen3) | 2.5 GB | 256K |
| [`qwen3:8b`](https://ollama.com/library/qwen3) | 5.2 GB | 40K |
| [`llama3.2:1b`](https://ollama.com/library/llama3.2) | 1.3 GB | 128K |
| [`llama3.2:3b`](https://ollama.com/library/llama3.2) | 2.0 GB | 128K |

`qwen3` is tagged `tools` and `thinking` on ollama.com; `llama3.2` is tagged `tools`. Note what is
*not* on this list: [`qwen3-coder`](https://ollama.com/library/qwen3-coder), the variant actually
tuned for agentic coding, starts at **30B / 19 GB**. The agentic-tuned small model does not exist.

**Verified:** `ollama pull qwen3:4b` produced a single 2,497,280,480-byte blob and 2.4 GB in
`~/.ollama`.

### Do they actually tool-call?

The model cards claim yes. [Qwen3-1.7B](https://huggingface.co/Qwen/Qwen3-1.7B) says "Qwen3 excels in
tool calling capabilities" and claims "Expertise in agent capabilities, enabling precise integration
with external tools" — but publishes no tool-use benchmark at all.
[Qwen3-4B-Instruct-2507](https://huggingface.co/Qwen/Qwen3-4B-Instruct-2507) does publish numbers:
**BFCL-v3 61.9**, TAU1-Retail 48.7, TAU1-Airline 32.0, TAU2-Retail 40.4, TAU2-Airline 24.0,
TAU2-Telecom 13.2. Read those TAU numbers as what they are: on multi-step agentic tasks with tools,
a 4B model finishes somewhere between a quarter and half the time. The
[Qwen3 launch blog](https://qwenlm.github.io/blog/qwen3/) claims "Improved Agentic Capabilities"
generally and publishes no agent benchmarks for the small dense models specifically.

So I tested it. Two experiments, both **verified** on this machine.

**Experiment A — hand-rolled loop, small tool schema.** A ~100-line Python agent loop against
`http://localhost:11434/v1/chat/completions` with two tools (`run_bash`, `read_file`) and a one-line
system prompt. `qwen3:4b`, fully GPU-offloaded (the server log confirms "offloaded 37/37 layers to
GPU"), generating at ~76 tok/s.

- Task "find the OS family and package manager": correct. 1 tool call, well-formed JSON, right
  answer, **124.8 s**.
- Task "work out three things, one tool call at a time": correct. It issued all three calls in one
  parallel batch, all well-formed, **87.3 s**. One caveat worth recording: the third command hit my
  safety allowlist and got back `REFUSED: command blocked by safety allowlist`, and the model
  reported "brew: no" — right answer, wrong reasoning. It read a tool *error* as a negative *result*.
  That is exactly the failure mode you cannot afford in a setup runbook.

So the raw capability is real. Small models can emit valid tool calls.

**Experiment B — a real harness.** This is the load-bearing result, and it took two runs to get an
honest answer out of it.

`opencode run --model ollama/qwen3:4b "Read the file sample.txt and tell me exactly what it
contains."` — a task with one obvious tool call and a 12-byte file. It ran for the full 300 s timeout
and was killed (exit 143). Rerun without a timeout: it exited 0 having printed nothing at all.

The `llama-server` log says why:

```
slot release: id 0 | task 5496 | stop processing: n_tokens = 3367, truncated = 1
slot release: id 0 | task 11886 | stop processing: n_tokens = 3161, truncated = 1
```

Two compounding numbers. First, **Ollama's default context on this machine is 4096 tokens** — the
startup log reads `msg="vram-based default context" total_vram="7.6 GiB" default_num_ctx=4096`, which
matches the documented tiers: "< 24 GiB VRAM: 4k context"
([docs.ollama.com/context-length](https://docs.ollama.com/context-length.md)). Second, `qwen3` is a
*thinking* model, and on those two turns it generated **5109 and 4664 tokens** of reasoning — each
turn's output alone exceeding the entire window. Truncation, then silence.

Raising the ceiling fixes the correctness and exposes the real problem. Restarted with
`OLLAMA_CONTEXT_LENGTH=32768` and rerun, the identical command **worked**:

```
> build · qwen3:4b
→ Read sample.txt
hello world

real    5m33.154s
```

Right answer. Three turns, with prompts of 543 → 6800 → 6972 tokens and a peak of 8937 tokens in
context, no truncation anywhere. **Five and a half minutes to read a 12-byte file.** Note what those
numbers mean for the default: a one-file, one-tool-call session is already 66% past Ollama's
VRAM-derived 4096-token window by its *second* turn. It is not the system prompt that kills it (the
first request was only 543 tokens); it's the thinking output plus the accumulated transcript, and it
happens immediately.

And raising the ceiling costs memory. The docs note only that "Setting a larger context length will
increase the amount of memory required to run a model", but the numbers are concrete: at 4096 tokens
the KV cache was 576 MiB, so 32k is ~4.6 GiB on top of 2.4 GiB of weights — which does not fit in
this machine's 7.6 GiB of VRAM without spilling to CPU and getting much slower. On a bare machine
with no discrete GPU it is worse still. **This is a real constraint, not a tuning oversight, and
every fix for it costs RAM the bootstrap machine may not have.**

`codex exec --oss --local-provider ollama -m qwen3:4b` failed differently and worse. Codex is not
logged in on this machine (no `~/.codex/auth.json`), so `--oss` is a clean test of the keyless path —
and it connected fine. The model then spent its entire 3,618-token budget reasoning *about codex's
tool schema* and never called anything. Verbatim from its output:

> Wait, the system's tool definition for spawn_agent has parameters: message (required), model,
> reasoning_effort, service_tier. Since the user didn't specify a model, omit it. […] Therefore, the
> function call is spawn_agent with that message.

It narrated a tool call instead of making one. A 4B model handed a frontier-sized harness prompt does
not degrade gracefully; it drowns.

For scale: this repo's own `AGENTS.md` + `steps/README.md` + both current step files total 9,040
characters, roughly 2.3k tokens. The runbook *content* fits in 4k. The *harness* does not.

## 2. Harnesses

Omarchy's [`install/user/mise.sh`](https://github.com/basecamp/omarchy/blob/master/install/user/mise.sh) installs `codex`, `claude`,
`crush`, `gemini`, `gh`, `copilot`, `opencode`, `playwright`, `pi`, `github:can1357/oh-my-pi` (as
`omp`), `grok`, `ghui` and `hunk`. Verified on this machine at
`/usr/share/omarchy/install/user/mise.sh`; each gets a thin wrapper in `~/.local/bin` that does
`mise use -g <pkg>` then `mise x`.

| harness | local endpoint? | starts with zero credentials? | keyless tier? |
| --- | --- | --- | --- |
| `opencode` | yes | **yes, verified** | no — Zen needs signup |
| `codex` | yes (`--oss`) | **yes, verified** | no |
| `pi` | yes (`models.json`) | no — refuses until a key exists | no |
| `omp` (oh-my-pi) | yes | not tested | no |
| `crush` | yes | not tested | Hyper free tier, needs a Charm account |
| `gemini` | no | no | no — free tier needs a Google login |
| `claude` | no | no | no |

**`pi`** is what the ticket asked about by name. It is [earendil-works/pi](https://github.com/earendil-works/pi),
Mario Zechner's agent toolkit — "AI agent toolkit: unified LLM API, agent loop, TUI, coding agent
CLI", BYOK across 40+ providers, four built-in tools (read, write, edit, bash). Its
[providers doc](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/providers.md)
covers Ollama, LM Studio, vLLM, and the llama.cpp router server (`/login llama.cpp`). **Verified:**
`mise install pi@latest` gave 110 MB, and `pi --list-models ollama` with a live Ollama on port 11434
returns:

```
No models available. Use /login to log into a provider via OAuth or API key.
```

pi does not auto-discover a local server, and its own shipped docs
(`~/.local/share/mise/installs/pi/0.84.2/pi/docs/models.md`) explain why:

> The `apiKey` value is a placeholder because Ollama ignores it. pi still treats models as requiring
> auth before they appear in `/model`, so keyless local servers should keep a dummy value, save a key
> for that provider with `/login`, or pass `--api-key` when selecting the model.

So pi works locally but needs a hand-written `~/.pi/agent/models.json` with a fake key first — a
config step on a machine that has nothing. It is not the "cheap no-auth agent" the ticket hoped for.

**`opencode`** is the best of them for this. **Verified:** with no credentials of any kind, a
project-local `opencode.json` of exactly the shape in
[its providers doc](https://opencode.ai/docs/providers/) —

```json
{ "provider": { "ollama": { "npm": "@ai-sdk/openai-compatible", "name": "Ollama (local)",
  "options": { "baseURL": "http://localhost:11434/v1" },
  "models": { "qwen3:4b": { "name": "Qwen3 4B" } } } } }
```

— was enough for `opencode run --model ollama/qwen3:4b` to start a session, reach the model, and
(with the context raised) complete a task, slowly (see Experiment B). Its free-model story is not keyless:
[opencode Zen](https://opencode.ai/docs/zen/) has several `Free` models, but "You sign in to OpenCode
Zen, add your billing details, and copy your API key."

One wrinkle that undercuts the offline story: **verified**, that first run created
`~/.config/opencode/node_modules` — 62 MB of npm packages including `@opencode-ai/plugin` and the
`@ai-sdk` package my config named. opencode fetches its provider SDK from the network on first use,
so "local model" does not mean "works with no network" for this harness.

**`codex`** has `--oss` / `--local-provider <lmstudio|ollama>` (verified in `codex --help` on this
machine) and, as noted, genuinely runs with no `auth.json`. Its default OSS model is `gpt-oss:20b`,
a [14 GB pull](https://ollama.com/library/gpt-oss) — pass `-m` explicitly or you'll get it.

**`crush`**'s [README](https://github.com/charmbracelet/crush) documents
`provider add ollama --type ollama --base-url "http://localhost:11434/v1/"` and auto-discovery for
`llamacpp`, `omlx`, `lmstudio`, `litellm`, `ollama`. Its quick path is "choose a Hyper model from
model picker" — Charm's own provider, with a free tier that still needs a Charm account.

**`omp`** ([can1357/oh-my-pi](https://github.com/can1357/oh-my-pi)) is a fork of pi with 60+
providers and explicit `local` tags on "Ollama · Ollama Cloud · LM Studio · llama.cpp · vLLM ·
LiteLLM", plus custom OpenAI-compatible providers via `~/.omp/agent/models.yml`. Not tested here;
inherits pi's shape.

**`gemini`** ([google-gemini/gemini-cli](https://github.com/google-gemini/gemini-cli)) has a generous
free tier — "60 requests/min and 1,000 requests/day with personal Google account" — but it is reached
through "Sign in with Google and follow the browser authentication flow". That is a browser login,
which is the thing we were trying to avoid, and the Google password is in 1Password too.

## 3. Keyless providers

The ticket asks for a hard line between *free tier* (needs signup, therefore needs a login, therefore
useless here) and *genuinely no account*. Almost everything is the first kind: Ollama Cloud requires
`ollama signin` ([docs.ollama.com/cloud](https://docs.ollama.com/cloud.md)), opencode Zen requires
billing details, Charm Hyper requires a Charm account, Gemini's free tier requires a Google login.

Two candidates claim otherwise. One fails, one holds.

**Pollinations — fails.** Its [API docs](https://github.com/pollinations/pollinations/blob/master/APIDOCS.md)
advertise "no signup required to get started!" and an anonymous tier of "One request every 15s" on
"Basic models", with an OpenAI-compatible endpoint and a documented function-calling example.
`https://text.pollinations.ai/models` does list one anonymous model (`openai-fast`, GPT-OSS 20B,
`"tier":"anonymous"`, `"tools":true`). **Verified: it does not work.** My first "Say OK" call returned
200, and so did the next two — with a byte-identical response id `pllns_1c646a82cbd909ff8f399bfafd62c2ca`
and an identical `created` timestamp. That was a *cache hit*, not inference. Every genuinely novel
prompt, with or without a `tools` array, returned:

```
HTTP:402  {"code":"PAYMENT_REQUIRED","message":"API key budget too low.
           This request costs ~0.0001 pollen, but this key has 0.0000."}
```

Four consecutive probes over two minutes, including the docs' own verbatim calculator example. The
documented anonymous tier is stale; the live service bills anonymous requests against a zero budget.
This is a good reminder that "the docs say keyless" is not evidence.

**OVHcloud AI Endpoints — holds.** This is the real answer, and it surprised me.
[OVHcloud's own getting-started guide](https://docs.ovhcloud.com/en/guides/public-cloud/ai-machine-learning/ai-endpoints-getting-started)
documents an unauthenticated tier in plain text:

> Anonymous: 2 requests per minute, per IP and per model.
>
> Authenticated with an API access key: 400 requests per minute, per PCI project and per model.

**Verified from this machine, with no account, no key and no `Authorization` header at all:**

```
POST https://oai.endpoints.kepler.ai.cloud.ovh.net/v1/chat/completions
{"model":"gpt-oss-20b", ..., "tools":[{"type":"function","function":{"name":"run_bash", ...}}]}

HTTP 200
"finish_reason":"tool_calls"
"tool_calls":[{"function":{"name":"run_bash","arguments":"{\"command\": \"ls -l /etc\"}"}}]
```

A correct, well-formed tool call from a 20B model, keyless. (Note: sending a *bogus* bearer token
gets a 403 — you must omit the header, not fake it.)

And then the rate limit eats it. **Verified:** I ran the same agent loop as Experiment A against it,
with a deliberate 31-second sleep before every turn to stay inside the documented 2/min:

```
[TURN 0] finish=tool_calls  -> run_bash({"command": "cat /etc/os-release"})    ✓
[TURN 1] finish=tool_calls  -> run_bash({"command": "pacman -Qe | wc -l"})     ✓ 176
[TURN 2] REQUEST FAILED: HTTP Error 429: Too Many Requests
=== DID NOT FINISH: 2 tool calls, 95.9s ===
```

Two correct tool calls in 96 seconds, then throttled out mid-task *while already sleeping half a
minute per turn*. At 2 requests per minute a six-call runbook step is three minutes of pure waiting
and a fifty-call session is 25 minutes — and in practice you get less than that. It works, and it is
unusable for anything past a handful of turns.

There is no third option. **No provider offers keyless inference at a rate an agent can work at.**

## 4. Disposability

Cheap, and cheaper than the download. All **verified** except the macOS lines.

**Linux, user-space (the path that needs no sudo):**

- runtime: `mise uninstall ollama` → reclaims 2.1 GB from `~/.local/share/mise/installs/ollama/`
- weights: `ollama rm qwen3:4b`, or `rm -rf ~/.ollama` → reclaims 2.4 GB (`~/.ollama/models/blobs/`;
  the server log confirms `OLLAMA_MODELS:/home/pavlos/.ollama/models`)
- harness: `mise uninstall opencode` → 176 MB, plus 62 MB in `~/.config/opencode` and 584 KB in
  `~/.local/share/opencode`. `mise uninstall pi` → 110 MB, plus `~/.pi/`.
- two gotchas, both **verified** by actually tearing this down afterwards. Running the mise shim
  wrote `opencode = "latest"` into `~/.config/mise/config.toml`, and `mise uninstall` does not undo
  that line. And `mise uninstall` leaves the version symlinks behind — after removing ollama,
  `~/.local/share/mise/installs/ollama/` still held `0`, `0.32` and `latest` all pointing at a
  `./0.32.14` that no longer existed. Both need `rm` by hand.
- the whole teardown took seconds and put `~/.local/share/mise` back to its exact pre-test size
  (966 MB), so the "disposable" half of the ticket's premise is sound.

**Linux, system-wide** (if you used `install.sh` or `pacman`): `pacman -Rns ollama`, or the four-step
manual removal in [docs.ollama.com/linux](https://docs.ollama.com/linux.md) — stop and disable the
service, `sudo rm -r $(which ollama | tr 'bin' 'lib')`, remove the binary, then
`userdel ollama`, `groupdel ollama`, `sudo rm -r /usr/share/ollama`. Note that this variant puts the
weights under `/usr/share/ollama`, not `$HOME`.

**macOS** (inferred from the [cask definition](https://formulae.brew.sh/api/cask/ollama-app.json),
not tested): the `ollama-app` cask's uninstall stanza is `launchctl com.ollama.ollama`,
`quit com.electron.ollama`, then removal of `/Applications/Ollama.app`; weights are in `~/.ollama`
per [docs.ollama.com/macos](https://docs.ollama.com/macos.md). Via mise it's the same
`mise uninstall ollama` plus `rm -rf ~/.ollama`.

Total to reclaim on the Linux path measured here: **~4.8 GB**. Removal is a couple of commands and
seconds. Disposability is not the problem — the 4.8 GB you spend to get there is.

## 5. The verdict

Against the incumbent — open a browser, sign into 1Password, sign into the agent, about a minute —
the no-auth path loses on every axis that matters:

- **Cost.** 4.8 GB of download (2.1 GB runtime + 2.5 GB weights + the harness) versus ~60 seconds.
  On a slow connection the download alone is longer than the whole login.
- **Capability and speed.** A 4B model emits valid tool calls in a toy loop, and inside opencode —
  once the context is raised to 32k — it does get the right answer. It takes **5m33s to read a
  12-byte file**. Left at the default context it produces no output at all, and inside codex it
  *narrated* a tool call instead of making one. Its own model card scores it 13–49 on TAU-bench.
  A runbook is dozens of steps; this is not a thing to hand your machine to.
- **It doesn't remove the login anyway.** The 1Password browser sign-in is still needed for
  everything downstream — GitHub, the Apple ID, the actual agent. All a local model buys is moving
  `xcode-select --install` earlier, and [#9](https://github.com/pvinis/setup/issues/9) already
  established macOS doesn't need CLT to get an agent up: mise and `claude` are both release binaries.
  **The chicken-and-egg this ticket set out to break was already broken.**
- **Compounding fragility.** The 4096-token default is a function of VRAM, so the *less* capable the
  machine, the *smaller* the window — exactly backwards. The one machine where you might want this is
  the one where it works worst.

The honest framing: this would be worth it if the login were expensive or impossible. It is neither,
on a desktop machine with a network connection.

### The one exception

**Headless, and only headless — and even then the answer is probably still no.**

The map lists headed-vs-headless as one of only two real axes, and a headless box is where the
incumbent actually strains: `claude` and `codex` OAuth flows want a browser. That's survivable (both
print a URL you can open elsewhere, and `ANTHROPIC_API_KEY` sidesteps it entirely), so it isn't a
wall — but it is the one place the argument is even coherent. Note the trap, though: headless boxes
are usually the ones *without* a GPU, and a 4B model on CPU at a few tokens per second is not an
agent, it's a slideshow.

The genuinely-offline case is cleaner but rarer: a machine with local files and no usable network
can't log in at all, and a pre-seeded Ollama is the only thing that runs. If that machine ever
appears, the recipe is known and cheap to write down. It has not appeared yet.

**Recommendation: don't build this.** Keep the two-block README from
[#9](https://github.com/pvinis/setup/issues/9). If it's ever revisited, the shape to revisit is
narrow and specific: **`opencode` + `ollama` + `qwen3:4b`, installed via `mise` so it needs no sudo
and no compiler on either OS, with `OLLAMA_CONTEXT_LENGTH` set to 32768 rather than left at the
VRAM-derived 4096.** Every other combination tested here is worse.

### The macOS footnote worth keeping

macOS 27 makes this question moot on Apple Silicon, for free. Apple's
[WWDC26 session 334](https://developer.apple.com/videos/play/wwdc2026/334/) says the `fm` command
line tool "comes pre-installed with macOS 27" and that "By default, it uses the on-device model that
comes with macOS, and that's always available", with `fm respond`, `fm chat`, and `fm schema` for
structured output. No download, no account, no network. This is the `fm` Pavlos floated on
[#9](https://github.com/pvinis/setup/issues/9), and it is real.

The caveats are real too. The model is "a compact, approximately 3-billion-parameter model" that
Apple itself says "is not designed to be a chatbot for general world knowledge"
([Apple ML research](https://machinelearning.apple.com/research/apple-foundation-models-2025-updates)) —
the same size class that failed Experiment B above. It needs Apple Intelligence enabled
(`appleIntelligenceNotEnabled` is one of the three documented unavailability reasons on
[`SystemLanguageModel.Availability`](https://developer.apple.com/documentation/foundationmodels/systemlanguagemodel),
alongside `deviceNotEligible` and `modelNotReady`), which per
[apple.com/apple-intelligence](https://www.apple.com/apple-intelligence/) means "Mac models with M1
and later" — Intel Macs are out — plus a supported Siri/device language. The framework supports tool
calling and guided generation; whether the *CLI* exposes tool calling is not confirmed by the session
transcript, only structured output via `fm schema` is.

So: worth a one-line check when a Mac is next in front of us (`fm respond "hi"`), and worth nothing
on Linux. It doesn't change the verdict, it just makes the macOS half of it free to re-test.
