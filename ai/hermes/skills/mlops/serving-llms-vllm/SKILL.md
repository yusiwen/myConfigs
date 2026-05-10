---
name: serving-llms-vllm
description: "vLLM: high-throughput LLM serving, OpenAI API, quantization."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos]

metadata:
  hermes:
    tags: [vllm, inference, serving, llm, quantization, gpu]
    category: mlops
---

# Serving LLMs with vLLM

vLLM is a high-throughput, memory-efficient LLM serving engine with an
OpenAI-compatible API. Key features: PagedAttention for near-zero KV cache
waste, continuous batching, prefix caching, tensor parallelism, and
quantization (FP8, INT4, AWQ, GPTQ, SqueezeLLM).

## Installation

```bash
pip install vllm           # CUDA 12.1+
# Or from source for latest features:
pip install vllm --pre     # pre-release
```

Requires NVIDIA GPU with compute capability 7.0+ (V100, A100, H100, RTX 30xx+).
AMD ROCm and Intel XPU builds available but less tested.

## Quick Start

```bash
# Serve a model (OpenAI-compatible endpoint at http://localhost:8000)
vllm serve meta-llama/Llama-3.1-8B-Instruct

# With tensor parallelism across GPUs
vllm serve meta-llama/Llama-3.1-70B-Instruct \
  --tensor-parallel-size 4 \
  --max-model-len 8192

# Query it
curl http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"meta-llama/Llama-3.1-8B-Instruct","messages":[{"role":"user","content":"Hello"}]}'
```

## Key CLI Flags

### Model & Weights

| Flag | Description |
|---|---|
| `--model` | Model name or HuggingFace path |
| `--revision` | Model revision/branch |
| `--dtype auto` (default) | auto, half, float16, bfloat16, float32 |
| `--max-model-len N` | Max sequence length (default: model's max) |
| `--tokenizer-mode auto` | auto or slow |
| `--trust-remote-code` | Trust custom HF code |
| `--download-dir PATH` | Cache directory for downloaded models |

### Parallelism & Distributed

| Flag | Description |
|---|---|
| `--tensor-parallel-size N` | TP across N GPUs (default: 1). Requires NVLink for >1. |
| `--pipeline-parallel-size N` | PP across N stages (default: 1) |
| `--distributed-executor-backend` | mp (multiprocess, default) or ray |
| `--worker-use-ray` | Use Ray for distributed workers (legacy) |
| `--num-scheduler-steps N` | Schedule N steps at once for higher throughput |

### Scheduling & Batching

| Flag | Description |
|---|---|
| `--max-num-seqs N` | Max concurrent sequences (default: 256). Limit is VRAM, not this number. |
| `--max-num-batched-tokens N` | Max tokens per batch iteration (default: 2048) |
| `--enable-prefix-caching` | Reuse KV cache for common prefixes (system prompts) |
| `--use-v2-block-manager` | Use v2 block manager (default: auto) |
| `--num-lookahead-slots N` | Slots for speculative decoding lookahead |

### Memory

| Flag | Description |
|---|---|
| `--gpu-memory-utilization F` | Fraction of GPU memory to use (default: 0.90) |
| `--swap-space N` | CPU swap space per GPU in GiB (default: 4) |
| `--block-size N` | KV block size in tokens (default: auto=16, 32 for long contexts) |
| `--max-seq-len-to-capture N` | Max seq len for CUDA graph capture |

### Quantization

| Flag | Description |
|---|---|
| `--quantization awq` | AWQ 4-bit |
| `--quantization gptq` | GPTQ |
| `--quantization fp8` | FP8 (H100 native or padded on older GPUs) |
| `--quantization squeezellm` | SqueezeLLM |
| `--quantization bitsandbytes` | bitsandbytes |
| `--quantization-param-path PATH` | Pre-computed quantization params |

### Multi-LoRA

| Flag | Description |
|---|---|
| `--enable-lora` | Enable LoRA adapters |
| `--max-lora-rank N` | Max LoRA rank (default: 64) |
| `--lora-modules` | Load LoRA modules at startup |

### Speculative Decoding

| Flag | Description |
|---|---|
| `--speculative-model MODEL` | Draft model for speculative decoding |
| `--num-speculative-tokens N` | Number of speculative tokens (default: 5) |
| `--speculative-draft-tensor-parallel-size N` | TP for draft model |
| `--ngram-prompt-lookup-max N` | N-gram prompt lookup size (no draft model needed) |
| `--spec-decoding-acceptance-method` | rejection (default) or typical_acceptance |

### Server

| Flag | Description |
|---|---|
| `--host` | Host to bind (default: 0.0.0.0) |
| `--port` | Port (default: 8000) |
| `--api-key KEY` | API key for client auth |
| `--served-model-name NAME` | Override model name in API |
| `--enable-auto-tool-choice` | Enable tool/function calling |
| `--chat-template PATH` | Custom chat template |
| `--response-role ASSISTANT` | Role name for assistant responses |

## Choosing Parallelism Settings

### Tensor Parallelism (TP)

**When:** Model weights exceed single GPU VRAM.

```bash
# 70B FP16 (~140 GB) on 4x A100 80 GB
vllm serve meta-llama/Llama-3.1-70B --tensor-parallel-size 4
```

Rule of thumb: `param_count x 2_bytes (FP16) / TP_size` <= GPU_mem x 0.90.

### Pipeline Parallelism (PP)

**When:** Model exceeds single-node VRAM or TP saturates (>8 GPUs).

```bash
vllm serve meta-llama/Llama-3.1-405B \
  --tensor-parallel-size 8 \
  --pipeline-parallel-size 2
```

PP adds latency. Prefer TP for latency-sensitive serving.

### Single GPU

Models that fit on one GPU (7B FP16, 8B FP8, 13B INT4).

## Memory Management

```
available_kv = total_VRAM x gpu_memory_utilization - model_weights
kv_per_token = 2 x num_layers x hidden_size x dtype_bytes
max_concurrent = available_kv / (kv_per_token x avg_seq_len)
```

LLaMA-70B FP16 on 8xH100: ~120 concurrent at 4K, ~60 at 8K.

## Quantization Guide

| Format | Bits | Hardware | Quality Loss |
|---|---|---|---|
| FP8 | 8 | H100 native | Very low |
| AWQ | 4 | Any | Low |
| GPTQ | 4 | Any | Low |
| SqueezeLLM | 3-4 | Any | Medium |

FP8 preferred on H100: 2x memory savings, native hardware support.

## Speculative Decoding

Draft model generates K tokens; target verifies in one forward pass.
1.5-3x throughput improvement.

```bash
vllm serve meta-llama/Llama-3.1-70B \
  --speculative-model meta-llama/Llama-3.1-8B \
  --num-speculative-tokens 5
```

N-gram mode (no draft model):
```bash
vllm serve ... \
  --ngram-prompt-lookup-max 4 \
  --ngram-prompt-lookup-min 1
```

## Monitoring

```bash
curl http://localhost:8000/metrics
```

Key metrics: `num_requests_running`, `gpu_cache_usage_perc`,
`avg_prompt_throughput_toks_per_s`, `time_to_first_token_seconds`.

## Common Pitfalls

- **OOM**: Lower `--gpu-memory-utilization` (try 0.85) or reduce `--max-num-seqs`
- **TP across nodes**: Don't. Use TP only within a node with NVLink.
- **Preemption warnings**: Reduce `--max-num-seqs` or add GPUs.
- **Docker**: Need `--shm-size 32g` or `/dev/shm` too small causes hangs.
- **Slow first token**: Set `--max-seq-len-to-capture` to typical prompt length.

## Related Wiki Pages

- [[parallel-request-capacity]] — Calculating concurrent requests from VRAM
- [[tensor-parallelism]] — How TP works under the hood
- [[pipeline-parallelism]] — When and why to use PP
- [[data-parallelism]] — DP for scaling throughput
