import modal
from pydantic import BaseModel
from typing import Optional

class GenerationOptions(BaseModel):
    temperature: float = 0.3
    top_k: int = -1
    top_p: float = 1.0

class GenerateRequest(BaseModel):
    model: Optional[str] = "navix-ai"
    prompt: str
    stream: Optional[bool] = False
    options: Optional[GenerationOptions] = GenerationOptions()

REPO_ID = "aw-s/qwen3_custom_modesl-Q4_K_M-GGUF"
FILENAME = "qwen3_custom_modesl-q4_k_m.gguf"

volume = modal.Volume.from_name("navix-model-weights", create_if_missing=True)

vllm_image = (
    modal.Image.debian_slim(python_version="3.10")
    .pip_install("vllm", "huggingface_hub", "hf_transfer", "pydantic")
)

app = modal.App("navix-api")

@app.function(image=vllm_image, volumes={"/data": volume}, timeout=3600)
def download_model():
    import os
    from huggingface_hub import hf_hub_download

    os.environ["HF_HUB_ENABLE_HF_TRANSFER"] = "1"

    print(f"Downloading {FILENAME} directly to persistent volume...")
    hf_hub_download(repo_id=REPO_ID, filename=FILENAME, local_dir="/data")

    volume.commit()
    print("Download complete! The model is saved.")

@app.cls(gpu="A10G", image=vllm_image, scaledown_window=300, volumes={"/data": volume})
class QwenModel:

    @modal.enter()
    def load_model(self):
        from vllm import LLM
        print("Loading GGUF model from Volume into VRAM...")

        self.llm = LLM(
            model=f"/data/{FILENAME}",
            tokenizer="unsloth/Qwen3-14B",
            trust_remote_code=True
        )

    @modal.fastapi_endpoint(method="POST")
    def generate(self, request: GenerateRequest):
        from vllm import SamplingParams

        sampling_params = SamplingParams(
            temperature=request.options.temperature,
            top_k=request.options.top_k,
            top_p=request.options.top_p,
            max_tokens=512,
            stop=["<|im_start|>", "<|im_end|>", "<|endoftext|>"]
        )

        system_prompt = "You are Navi, the friendly and energetic mascot AI of the Navix app."
        formatted_prompt = f"<|im_start|>system\n{system_prompt}<|im_end|>\n<|im_start|>user\n{request.prompt}<|im_end|>\n<|im_start|>assistant\n"

        outputs = self.llm.generate([formatted_prompt], sampling_params)
        generated_text = outputs[0].outputs[0].text.strip()

        return {"response": generated_text}
