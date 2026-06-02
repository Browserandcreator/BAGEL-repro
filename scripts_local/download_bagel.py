from huggingface_hub import snapshot_download

repo_id = "ByteDance-Seed/BAGEL-7B-MoT"
save_dir = "/root/autodl-tmp/BAGEL/models/BAGEL-7B-MoT"

snapshot_download(
    repo_id=repo_id,
    local_dir=save_dir,
    resume_download=True,
    allow_patterns=[
        "*.json",
        "*.safetensors",
        "*.bin",
        "*.py",
        "*.md",
        "*.txt",
        "*.model",
        "tokenizer*",
    ],
)
