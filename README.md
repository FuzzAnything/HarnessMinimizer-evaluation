# HarnessMinimizer

![This repository contains code and commands for reproducing the paper's evaluation experiments.](docs/assets/evaluation-purpose.svg)

## Installation

Build the image and create the container from the repository root.

```bash
./setup_docker.sh
```

Enter the container and select the repository directory.

```bash
docker exec -it harnessminimizer-eval bash
cd /root/HarnessMinimizer
```

Run the remaining installation commands from this directory inside the container.

Install the Python package and activate its environment using uv.

```bash
uv sync
source .venv/bin/activate
```

Install the prerequisites for Perses, WDD, CDD.

```bash
apt-get update
apt-get install -y openjdk-17-jdk-headless coreutils unzip zip
```

Install Bazelisk to build the Perses engines.

```bash
mkdir -p .tools/bin
curl -fL --retry 3 \
  https://github.com/bazelbuild/bazelisk/releases/download/v1.29.0/bazelisk-linux-amd64 \
  -o .tools/bin/bazelisk
chmod +x .tools/bin/bazelisk
export PATH="$(pwd)/.tools/bin:$PATH"
```

Build and install the pinned Perses revision.

```bash
mkdir -p .tools/perses
git clone https://github.com/uw-pluverse/perses.git .tools/perses/source
git -C .tools/perses/source checkout --detach 6c6ae0db20fa83b0f85a71ca447f0c4d5e056bd2
python tools/perses/install.py --source .tools/perses/source --jobs 2
```

Install and select patched treereduce.

```bash
python tools/treereduce/install.py
export HARNESSMINIMIZER_TREEREDUCE="$(pwd)/.tools/bin/treereduce-c"
```

## Evaluation

This section contains commands to rerun the evaluation experiments of the paper.

Run these commands from the repository root with the benchmark data available under `benchmark/`.

GitHub limits repository file sizes, so build the benchmark libraries locally. For each case, check out the library's Git commit SHA listed in [library_version.csv](library_version.csv), build its dynamic (`.so`) and static (`.a`) libraries, and place them in that case's `build/sanitizer/lib/` folder under `benchmark/harness-bug/` or `benchmark/library-bug/`. Don't forget to instrument the libraries with AddressSanitizer and UndefinedBehaviorSanitizer (`-fsanitize=address,undefined`) when building them.

### Speedup Performance

Run performance evaluation for all four engines across both datasets.

```bash
./run_harnessminimizer_evaluation.sh --tool all
```

### Crash Triage

Create the crash-triage configuration.

```bash
cp .env-template .env
```

Fill in `OPENAI_BASE_URL`, `LLM_API_KEY`, and `OPENAI_MODEL` in `.env`.

Run crash triage with n worker using the latest performance evaluation batch (n parallel requests to LLM).

```bash
./run_crash_triage_parallel.sh --tool all --jobs n
```

Retry failed or unfinished triage cases with n workers (timeout or LLM failing to follow the instructions).

```bash
./run_crash_triage_parallel.sh --tool all --jobs n --resume
```

### FDP Replay Function Evaluation

Run the replay experiment across all cases with 10 treereduce workers per reduction. Note that `--jobs` here is not the same as `--jobs` in the crash triage evaluation. For crash triage, it means parallel requests to LLM. Here it means number of workers of the reduction engine. The same for crash oracle evaluation.

```bash
./run_replay_evaluation.sh --jobs 10
```

Resume replay evaluation, retrying failed or incomplete cases.

```bash
./run_replay_evaluation.sh --jobs 10 --resume
```

### Crash Oracle Evaluation

Run the oracle experiment across both datasets.

```bash
./run_oracle_evaluation.sh --jobs 10
```

Resume oracle evaluation, retrying failed or incomplete cases.

```bash
./run_oracle_evaluation.sh --jobs 10 --resume
```

For replay and oracle experiments, `--jobs` defaults to 10 reducer workers; `--parallel` defaults to one concurrent case, increase `--parallel` to run different cases in parallel. Results are saved under `output/replay-evaluation/` and `output/oracle-evaluation/`; use `--results-root` to choose another location.

For the open-source HarnessMinimizer tool, visit [FuzzAnything/HarnessMinimizer](https://github.com/FuzzAnything/HarnessMinimizer).

## License

This repository contains components under different licenses. [LICENSE](LICENSE) records their scope and identifies the evaluation files covered by MIT.

1. **HarnessMinimizer code.** Code copied or adapted from the main repository is subject to the [original HarnessMinimizer license](https://github.com/FuzzAnything/HarnessMinimizer/blob/main/LICENSE): **AGPL-3.0-only**, or a separately negotiated commercial license. A complete copy is included in [LICENSE.HarnessMinimizer](LICENSE.HarnessMinimizer). The commercial option requires a separate agreement with the applicable copyright holders.
2. **Per-file licenses and evaluation code.** Original evaluation modules, scripts, and tests marked `SPDX-License-Identifier: MIT` may be reused under [LICENSE.MIT](LICENSE.MIT). Check the license notices at the beginning of each source file. The MIT grant for an evaluation file does not replace the license obligations for HarnessMinimizer code used with it. Files containing third-party material also retain the applicable upstream conditions.
3. **Third-party components.** LLVM code and tools retain **Apache-2.0 WITH LLVM-exception** terms, treereduce retains its **MIT** terms, and the separately obtained Perses engines retain **GPL-3.0-or-later** terms. See [THIRD_PARTY_NOTICES](THIRD_PARTY_NOTICES) and [THIRD_PARTY_LICENSES](THIRD_PARTY_LICENSES/) for attribution, component details, and the included license texts. Benchmark materials and other dependencies retain their applicable permissions and notices.

![This repository contains code and commands for reproducing the paper's evaluation experiments.](docs/assets/evaluation-purpose.svg)
