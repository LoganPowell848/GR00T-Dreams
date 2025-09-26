# NPS Hamming Metadata Templates

This directory contains editable templates that allow you to plug the Naval Postgraduate School (NPS) **Hamming** platform into the DreamGen IDM toolchain.

1. **`config.json`** — Drives the dynamic data configuration that is loaded by `NpsHammingDataConfig`. Update the modality key names, horizons and normalization strategy to match your LeRobot dataset.
2. **`modality.json`** — Mirrors the LeRobot `meta/modality.json` file produced after converting your dataset. Adjust the start/end indices and modality names to reflect the true layout exported by your data pipeline.
3. **`stats.json`** — Placeholder that will be automatically replaced by `LeRobotSingleDataset` the first time you load an NPS Hamming dataset. If you prefer to bake the statistics ahead of time, run a short Python snippet that instantiates `LeRobotSingleDataset` with your converted dataset path; the loader will materialize `meta/stats.json` automatically.

> **Tip:** keep these files under version control together with your dataset generation scripts so team members can collaborate on any schema updates.
