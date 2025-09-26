#!/usr/bin/env bash
set -euo pipefail

# 1. Convert the raw DreamGen output directory into the structure expected by the IDM pipeline.
python IDM_dump/convert_directory.py \
    --input_dir "<COSMOS_PREDICT2_OUTPUT_DIR>" \
    --output_dir "results/dream_gen_benchmark/cosmos_predict2_nps_hamming_step3"

# 2. Preprocess the videos into per-modality folders and resolution expected by LeRobot.
python IDM_dump/preprocess_video.py \
    --src_dir "results/dream_gen_benchmark/cosmos_predict2_nps_hamming_step3" \
    --dst_dir "IDM_dump/data/nps_hamming_processed" \
    --dataset nps_hamming \
    --original_width 1920 \
    --original_height 1080 \
    --recursive

# 3. Convert the processed assets into the unified LeRobot format.
python IDM_dump/raw_to_lerobot.py \
    --input_dir "IDM_dump/data/nps_hamming_processed" \
    --output_dir "IDM_dump/data/nps_hamming_unified.data" \
    --cosmos_predict2 \
    --embodiment "nps_hamming" \
    --video_key "observation.images.front_view"

# 4. (Optional) Dump IDM actions using a checkpoint trained for the Hamming platform.
# Replace the checkpoint argument with your local path or a Hugging Face repo ID.
python IDM_dump/dump_idm_actions.py \
    --checkpoint "<PATH_OR_HF_REPO_FOR_NPS_HAMMING_IDM>" \
    --dataset "IDM_dump/data/nps_hamming_unified.data" \
    --output_dir "IDM_dump/data/nps_hamming_unified.data_idm" \
    --num_gpus 8 \
    --video_indices "0 8"
