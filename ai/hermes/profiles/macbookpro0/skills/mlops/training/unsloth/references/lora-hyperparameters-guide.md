# LoRA & QLoRA Hyperparameters Guide

Sourced from Unsloth's official docs. Full guide: https://docs.unsloth.ai/get-started/fine-tuning-llms-guide/lora-hyperparameters-guide

---

## What is LoRA?

LoRA (Low-Rank Adaptation) freezes original model weights and injects two thin matrices A (r × k) and B (d × r) into each linear layer. Only these adapters are trained — ~1% of total parameters.

```
W_hat = W + (alpha / r) × A × B
```

## Key Hyperparameters

| Parameter | What it controls | Recommendation |
|-----------|-----------------|---------------|
| **Rank (r)** | Number of trainable params in the adapter. Higher = more capacity, more memory. Larger ranks risk overfitting. | 8, 16, 32, 64, 128. Start at **16 or 32**. |
| **Alpha (lora_alpha)** | Scales the contribution of the adapter. | Set to `r` or `r * 2` so `alpha / r >= 1` |
| **Target Modules** | Which linear layers to apply LoRA to. | ALL: `q_proj, k_proj, v_proj, o_proj, gate_proj, up_proj, down_proj` |
| **Dropout** | Randomly zeroes activations for regularization. | 0 (default) — unreliable for short fine-tuning runs (arXiv:2410.09692) |
| **Learning Rate** | Step size for adapter weight updates. | `2e-4` for fine-tuning, `5e-6` for RL (DPO/GRPO) |
| **Epochs** | Full passes over the dataset. | 1-3. More risks overfitting. |
| **Weight Decay** | Regularization term penalizing large weights. | 0.01 (recommended) - 0.1 |
| **Warmup Steps** | Gradually increases LR at the start. | 5-10% of total steps |
| **Scheduler** | Dynamic LR adjustment during training. | `linear` or `cosine` |
| **Bias** | Whether to train bias terms. | `"none"` (optimized for speed/memory) |
| **Gradient Checkpointing** | Trade compute for memory. | `"unsloth"` (reduces VRAM 30%, supports long context) |

## LoRA vs QLoRA

| Feature | LoRA (16-bit) | QLoRA (4-bit NF4) |
|---------|---------------|-------------------|
| Base model precision | FP16/BF16 | 4-bit NF4 |
| VRAM | Baseline | **4× less** |
| Speed | Slightly faster | Slightly slower |
| Accuracy | Baseline | ~1% lower (negligible) |
| Best for | Max accuracy setups | Consumer GPUs, large models (70B in <48GB) |

**QLoRA** (arXiv:2305.14314) quantizes the base model to 4-bit Normalized Float (NF4) while keeping LoRA adapters in 16-bit.

## Advanced Variants

### rsLoRA (Rank-Stabilized LoRA)
- Paper: arXiv:2312.03732
- Scaling formula: `alpha / sqrt(r)` instead of `alpha / r`
- Theoretically optimal for high ranks — LR needs to shrink only as `sqrt(r)` not `r`
- Enable: `use_rslora=True`

### LoftQ
- Paper: arXiv:2310.08659
- Initializes LoRA matrices with top-r singular vectors of quantized weights via SVD
- Improves accuracy at cost of memory spike at init
- Configurable via `loftq_config`

## Training on Completions Only

Mask out user/instruction tokens, train only on assistant responses. Adds ~1% accuracy, especially for multi-turn conversations.

```python
from unsloth.chat_templates import train_on_responses_only
trainer = train_on_responses_only(
    trainer,
    instruction_part = "<|start_header_id|>user<|end_header_id|>\n\n",
    response_part = "<|start_header_id|>assistant<|end_header_id|>\n\n",
)
```

## Overfitting Prevention

- If training loss drops below 0.2 → model is overfitting
- Multiply LoRA alpha by 0.5 post-training (equivalent to weight-averaging with base model)
- Reduce epochs, increase weight_decay, increase lora_dropout
- Increase batch size or gradient accumulation steps
- Use evaluation early stopping

## Effective Batch Size

```
Effective Batch Size = batch_size × gradient_accumulation_steps
```

| Parameter | Recommendation |
|-----------|---------------|
| batch_size | 2 |
| gradient_accumulation_steps | 8 |
| Effective Batch Size | 16 |

Unsloth's gradient accumulation fix makes all batch_size/gradient_accumulation_steps combinations equivalent with identical loss curves.

## Recommended LoRA Config (Unsloth Defaults)

```python
r = 16
lora_alpha = 16
target_modules = ["q_proj", "k_proj", "v_proj", "o_proj",
                  "gate_proj", "up_proj", "down_proj"]
lora_dropout = 0
bias = "none"
use_gradient_checkpointing = "unsloth"
random_state = 3407
use_rslora = False
loftq_config = None
```
