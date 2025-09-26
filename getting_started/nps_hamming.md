# Integrating the NPS Hamming Platform

This guide describes how to adapt the DreamGen IDM pipeline for the Naval Postgraduate School (NPS) **Hamming** robot. The workflow mirrors the existing embodiments (GR1, Franka, SO-100, RoboCasa) and reuses the same preprocessing utilities.

## 1. Prepare metadata templates

1. Copy your converted LeRobot dataset (or its schema) to determine the joint ordering and camera modalities used by Hamming.
2. Edit the files under [`IDM_dump/global_metadata/nps_hamming`](../IDM_dump/global_metadata/nps_hamming):
   - Update `modality.json` so the `start`/`end` indices match the flattened observation and action vectors exported by your simulator or robot logs.
   - Adjust `config.json` to list the modality keys you want to expose to the IDM (e.g., rename `state.joints` if you track base, torso or head separately). You can also tweak the default image processing hyperparameters here.
   - Leave `stats.json` as-is; it acts as a placeholder and will be regenerated automatically the first time you load the dataset with `LeRobotSingleDataset`.

> **Tip:** commit any local edits to these files alongside your dataset configuration so the entire team uses a consistent schema.

## 2. Restructure DreamGen videos

Use `IDM_dump/convert_directory.py` to reshape the Cosmos output into the folder layout expected by the IDM preprocessing tools.

```bash
python IDM_dump/convert_directory.py \
    --input_dir "<COSMOS_PREDICT2_OUTPUT_DIR>" \
    --output_dir "results/dream_gen_benchmark/cosmos_predict2_nps_hamming_step3"
```

## 3. Preprocess frames for LeRobot

Run the dedicated helper script (or invoke the command manually) to crop, resize and split the raw frames. The defaults assume a 1920×1080 single front-view camera; update `--original_width` / `--original_height` if your setup differs.

```bash
python IDM_dump/preprocess_video.py \
    --src_dir "results/dream_gen_benchmark/cosmos_predict2_nps_hamming_step3" \
    --dst_dir "IDM_dump/data/nps_hamming_processed" \
    --dataset nps_hamming \
    --original_width 1920 \
    --original_height 1080 \
    --recursive
```

Alternatively, run [`IDM_dump/scripts/preprocess/nps_hamming.sh`](../IDM_dump/scripts/preprocess/nps_hamming.sh) to execute the entire pipeline end-to-end.

## 4. Convert to LeRobot format

```bash
python IDM_dump/raw_to_lerobot.py \
    --input_dir "IDM_dump/data/nps_hamming_processed" \
    --output_dir "IDM_dump/data/nps_hamming_unified.data" \
    --cosmos_predict2 \
    --embodiment "nps_hamming" \
    --video_key "observation.images.front_view"
```

Once finished, the directory will contain a standard LeRobot dataset with `meta/` and `videos/` sub-folders.

## 5. (Optional) Dump IDM actions or finetune

* **Inference:** supply an IDM checkpoint trained for Hamming to `IDM_dump/dump_idm_actions.py`. The script now recognises the new `nps_hamming` embodiment tag and will leverage the metadata you edited earlier.
* **Training:** point `scripts/idm_training.py` to `--data-config nps_hamming` and set `--embodiment_tag nps_hamming` (or another string if you wish to override the tag embedded in your dataset).

After these steps you can reuse the existing GR00T N1 fine-tuning recipes with the synthetic trajectories generated for the NPS Hamming platform.
