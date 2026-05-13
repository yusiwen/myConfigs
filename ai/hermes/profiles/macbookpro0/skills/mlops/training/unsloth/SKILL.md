---
name: unsloth
description: "Unsloth: 2-5x faster LoRA/QLoRA fine-tuning, less VRAM."
version: 1.0.0
author: Orchestra Research
license: MIT
dependencies: [unsloth, torch, transformers, trl, datasets, peft]
platforms: [linux, macos]
metadata:
  hermes:
    tags: [Fine-Tuning, Unsloth, Fast Training, LoRA, QLoRA, Memory-Efficient, Optimization, Llama, Mistral, Gemma, Qwen]

---

# Unsloth Skill

Comprehensive assistance with unsloth development, generated from official documentation.

## When to Use This Skill

This skill should be triggered when:
- Working with unsloth
- Asking about unsloth features or APIs
- Implementing unsloth solutions
- Debugging unsloth code
- Learning unsloth best practices

## Quick Reference

### LoRA/QLoRA at a Glance

| Concept | Summary |
|---------|---------|
| **LoRA** | Freeze base weights, train small A/B matrices (~1% of params). Scaling: `alpha / r`. |
| **QLoRA** | LoRA + 4-bit NF4 base model. Uses 4× less VRAM with ~1% accuracy loss. |
| **rsLoRA** | Uses `alpha / sqrt(r)` scaling. Better for high ranks. Enable via `use_rslora=True`. |
| **LoftQ** | SVD-initialized LoRA for quantized models. Config: `loftq_config`. |
| **Train on completions** | Mask user tokens, train only on assistant responses. +1% accuracy. |

### Key Hyperparameters

- **Rank (r)**: Start at 16 or 32. Higher = more capacity + more VRAM + overfitting risk.
- **Alpha**: Set to `r` or `r * 2` (alpha/rank >= 1).
- **Target modules**: Always target ALL linear layers (attention + MLP) — research shows this is critical to match full fine-tuning.
- **Learning rate**: `2e-4` for fine-tuning, `5e-6` for RL (DPO/GRPO).
- **Epochs**: 1-3 max. If loss < 0.2, you're overfitting.
- **Gradient checkpointing**: Use `"unsloth"` for 30% less VRAM.
- **Dropout**: Keep at 0 — unreliable for short fine-tuning runs.

### Overfitting Fixes

1. Scale LoRA alpha down (multiply by 0.5) post-training
2. Reduce epochs, increase weight_decay (0.01), increase lora_dropout (0.1)
3. Increase batch size or gradient accumulation
4. Use evaluation early stopping

## Reference Files

This skill includes comprehensive documentation in `references/`:

- **llms-txt.md** - Llms-Txt documentation
- **lora-hyperparameters-guide.md** - LoRA/QLoRA hyperparameters, advanced variants, best practices (new)

Use `view` to read specific reference files when detailed information is needed.

## Working with This Skill

### For Beginners
Start with the getting_started or tutorials reference files for foundational concepts.

### For Specific Features
Use the appropriate category reference file (api, guides, etc.) for detailed information.

### For Code Examples
The quick reference section above contains common patterns extracted from the official docs.

## Resources

### references/
Organized documentation extracted from official sources. These files contain:
- Detailed explanations
- Code examples with language annotations
- Links to original documentation
- Table of contents for quick navigation

### scripts/
Add helper scripts here for common automation tasks.

### assets/
Add templates, boilerplate, or example projects here.

## Notes

- This skill was automatically generated from official documentation
- Reference files preserve the structure and examples from source docs
- Code examples include language detection for better syntax highlighting
- Quick reference patterns are extracted from common usage examples in the docs

## Updating

To refresh this skill with updated documentation:
1. Re-run the scraper with the same configuration
2. The skill will be rebuilt with the latest information

<!-- Trigger re-upload 1763621536 -->



