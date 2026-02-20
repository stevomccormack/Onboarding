# .shared/variables/ollama.ps1

# -------------------------------------------------------------------------------------------------
# Ollama - Locally Hosted AI Models
# -------------------------------------------------------------------------------------------------
# Ollama allows you to run large language models (LLMs) locally on your machine.
# Models are pulled from the Ollama registry and run via a local inference server.
#
# CLI Usage:
#   ollama pull <model>        # Download a model
#   ollama run <model>         # Run an interactive session
#   ollama list                # List downloaded models
#   ollama rm <model>          # Remove a model
#   ollama show <model>        # Show model details
#   ollama serve               # Start the Ollama server manually
#
# Hardware Guidance (PIPELINE: Ryzen 7 9800X3D | RTX 5080 16 GB VRAM | 47 GB RAM):
#   8–16 GB RAM, no GPU         → llama3.2:3b, phi4, gemma3:4b (quantized)
#   16–32 GB RAM / light GPU    → mistral, llama3.1:8b, gemma3:12b
#   32 GB+ RAM or GPU           → llama3.1:70b, mistral-large, qwen2.5:72b
#
# Performance Tips:
#   - Use GGUF quantized builds (Q4/Q5) for significantly faster CPU inference
#   - Load models selectively — avoid pre-loading large models
#   - Use Q4_K_M quantization for best CPU speed/quality balance
#   - RTX 5080 (16 GB VRAM) can fully GPU-accelerate models up to ~13B
#   - Models up to ~40B can use partial GPU offloading with remaining layers in RAM
# -------------------------------------------------------------------------------------------------

$ollamaInstallUrl  = 'https://ollama.com/install.ps1'
$ollamaDocsUrl     = 'https://ollama.com/docs'
$ollamaModelsUrl   = 'https://ollama.com/library'
$ollamaApiBaseUrl  = 'http://localhost:11434'

# -------------------------------------------------------------------------------------------------

$Ollama = [pscustomobject]@{
    InstallUrl  = $ollamaInstallUrl     # Ollama install script URL
    DocsUrl     = $ollamaDocsUrl        # Ollama documentation
    ModelsUrl   = $ollamaModelsUrl      # Ollama model library / registry
    ApiBaseUrl  = $ollamaApiBaseUrl     # Local REST API base URL (Ollama server)
    CommandName = 'ollama'              # CLI command name
    TestCommand = 'ollama --version'    # Command used to verify installation

    # -----------------------------------------------------------------------------------------
    # Models
    # -----------------------------------------------------------------------------------------
    # Each entry: Id, Enabled, Name, Provider, Url
    #   Id       - Ollama pull identifier  (ollama pull <Id>)
    #   Enabled  - Pull during onboarding  (✅ enabled  |  ⬜ disabled)
    #   Name     - Human-readable label
    #   Provider - Organisation that released the model
    #   Url      - Ollama library page
    #
    # Enabled = $true  → pulled on PIPELINE (RTX 5080, 47 GB RAM)
    # Enabled = $false → available to enable manually; not pulled by default
    # -----------------------------------------------------------------------------------------
    Models = @(

        # =================================================================================
        # 🦙  META — Llama Family  (most downloaded models on Ollama)
        # =================================================================================
        # Llama 3.3 70B | Size: 70B | MinRAM: 40 GB | Rating: ⭐⭐⭐⭐⭐
        # BestFor  : Best overall open model; state-of-the-art reasoning and chat
        # Notes    : ✅ Partial GPU offload on RTX 5080; remainder in 47 GB RAM
        @{ Id = 'llama3.3';          Enabled = $true;  Name = 'Llama 3.3 70B';        Provider = 'Meta';      Url = 'https://ollama.com/library/llama3.3' }

        # Llama 3.1 8B | Size: 8B | MinRAM: 8 GB | Rating: ⭐⭐⭐⭐⭐
        # BestFor  : Fast everyday chat and reasoning; fully fits in RTX 5080 VRAM
        # Notes    : ✅ Flagship daily-driver — latest Llama generation, fully on GPU
        @{ Id = 'llama3.1';          Enabled = $true;  Name = 'Llama 3.1 8B';         Provider = 'Meta';      Url = 'https://ollama.com/library/llama3.1' }

        # Llama 3.2 3B | Size: 3B | MinRAM: 4 GB | Rating: ⭐⭐⭐⭐
        # BestFor  : Ultra-fast responses, edge/low-power use, quick Q&A
        # Notes    : ⬜ Great for scripted automation; outclassed by 3.1:8b for quality
        @{ Id = 'llama3.2';          Enabled = $false; Name = 'Llama 3.2 3B';         Provider = 'Meta';      Url = 'https://ollama.com/library/llama3.2' }

        # Llama 3.1 70B | Size: 70B | MinRAM: 40 GB | Rating: ⭐⭐⭐⭐⭐
        # BestFor  : Heavy reasoning, complex analysis, long-context tasks
        # Notes    : ⬜ Superseded by llama3.3 — use that instead
        @{ Id = 'llama3.1:70b';      Enabled = $false; Name = 'Llama 3.1 70B';        Provider = 'Meta';      Url = 'https://ollama.com/library/llama3.1' }

        # Llama 2 13B | Size: 13B | MinRAM: 16 GB | Rating: ⭐⭐⭐
        # BestFor  : Legacy reasoning/writing; fine-tuning base model
        # Notes    : ⬜ Superseded by Llama 3.x — kept for reference/compatibility
        @{ Id = 'llama2:13b';        Enabled = $false; Name = 'Llama 2 13B';          Provider = 'Meta';      Url = 'https://ollama.com/library/llama2' }

        # Llama 2 7B | Size: 7B | MinRAM: 8 GB | Rating: ⭐⭐⭐
        # BestFor  : Legacy use; fine-tuning base
        # Notes    : ⬜ Outdated — use llama3.1 or mistral instead
        @{ Id = 'llama2';            Enabled = $false; Name = 'Llama 2 7B';           Provider = 'Meta';      Url = 'https://ollama.com/library/llama2' }

        # =================================================================================
        # 🌬️  MISTRAL AI — Mistral Family  (top quality-per-parameter models)
        # =================================================================================
        # Mistral 7B | Size: 7B | MinRAM: 8 GB | Rating: ⭐⭐⭐⭐⭐
        # BestFor  : General purpose, fast reasoning, creative writing
        # Notes    : ✅ Excellent all-rounder; fully fits in RTX 5080 VRAM
        @{ Id = 'mistral';           Enabled = $true;  Name = 'Mistral 7B';           Provider = 'Mistral AI'; Url = 'https://ollama.com/library/mistral' }

        # Mistral Small 22B | Size: 22B | MinRAM: 16 GB | Rating: ⭐⭐⭐⭐⭐
        # BestFor  : Balanced chat, reasoning and writing at mid-tier size
        # Notes    : ✅ Partially GPU-offloaded on RTX 5080; strong quality jump from 7B
        @{ Id = 'mistral-small';     Enabled = $true;  Name = 'Mistral Small 22B';    Provider = 'Mistral AI'; Url = 'https://ollama.com/library/mistral-small' }

        # Mistral Nemo 12B | Size: 12B | MinRAM: 12 GB | Rating: ⭐⭐⭐⭐
        # BestFor  : Efficient mid-tier; long context (128K), multilingual
        # Notes    : ⬜ Good alternative to mistral-small if VRAM is a concern
        @{ Id = 'mistral-nemo';      Enabled = $false; Name = 'Mistral Nemo 12B';     Provider = 'Mistral AI'; Url = 'https://ollama.com/library/mistral-nemo' }

        # Mixtral 8x7B | Size: 8x7B MoE (~47B total) | MinRAM: 26 GB | Rating: ⭐⭐⭐⭐⭐
        # BestFor  : High-quality chat + reasoning with MoE efficiency
        # Notes    : ⬜ Requires partial GPU offload; excellent quality if hardware allows
        @{ Id = 'mixtral';           Enabled = $false; Name = 'Mixtral 8x7B';         Provider = 'Mistral AI'; Url = 'https://ollama.com/library/mixtral' }

        # Mistral Large 123B | Size: 123B | MinRAM: 80+ GB | Rating: ⭐⭐⭐⭐⭐
        # BestFor  : Flagship-quality reasoning; near GPT-4 performance
        # Notes    : ⬜ Exceeds PIPELINE RAM — requires quantization or server-grade hardware
        @{ Id = 'mistral-large';     Enabled = $false; Name = 'Mistral Large 123B';   Provider = 'Mistral AI'; Url = 'https://ollama.com/library/mistral-large' }

        # =================================================================================
        # 🔵  MICROSOFT — Phi Family  (small but surprisingly capable)
        # =================================================================================
        # Phi-4 14B | Size: 14B | MinRAM: 10 GB | Rating: ⭐⭐⭐⭐⭐
        # BestFor  : Reasoning, maths, science — punches well above its size
        # Notes    : ✅ Fully fits in RTX 5080 VRAM; highly recommended for dev tasks
        @{ Id = 'phi4';              Enabled = $true;  Name = 'Phi-4 14B';            Provider = 'Microsoft'; Url = 'https://ollama.com/library/phi4' }

        # Phi-3 Mini 3.8B | Size: 3.8B | MinRAM: 4 GB | Rating: ⭐⭐⭐⭐
        # BestFor  : Fast, lightweight chat and reasoning on low-power hardware
        # Notes    : ⬜ Superseded by phi4 on PIPELINE; useful for edge/automation use
        @{ Id = 'phi3';              Enabled = $false; Name = 'Phi-3 Mini 3.8B';      Provider = 'Microsoft'; Url = 'https://ollama.com/library/phi3' }

        # Phi-3 Medium 14B | Size: 14B | MinRAM: 10 GB | Rating: ⭐⭐⭐⭐
        # BestFor  : Mid-tier reasoning; slightly older than phi4
        # Notes    : ⬜ Use phi4 instead — newer and better at same size
        @{ Id = 'phi3:14b';          Enabled = $false; Name = 'Phi-3 Medium 14B';     Provider = 'Microsoft'; Url = 'https://ollama.com/library/phi3' }

        # =================================================================================
        # 🟦  GOOGLE — Gemma Family  (open-source from Google DeepMind)
        # =================================================================================
        # Gemma 3 12B | Size: 12B | MinRAM: 10 GB | Rating: ⭐⭐⭐⭐⭐
        # BestFor  : Strong general chat, reasoning, multilingual — Google's best open model
        # Notes    : ✅ Fully fits in RTX 5080 VRAM; top pick from Google's open lineup
        @{ Id = 'gemma3:12b';        Enabled = $true;  Name = 'Gemma 3 12B';          Provider = 'Google';    Url = 'https://ollama.com/library/gemma3' }

        # Gemma 3 27B | Size: 27B | MinRAM: 20 GB | Rating: ⭐⭐⭐⭐⭐
        # BestFor  : Google's flagship open model; strong reasoning + vision capability
        # Notes    : ⬜ Partial GPU offload on RTX 5080; excellent quality step up from 12B
        @{ Id = 'gemma3:27b';        Enabled = $false; Name = 'Gemma 3 27B';          Provider = 'Google';    Url = 'https://ollama.com/library/gemma3' }

        # Gemma 3 4B | Size: 4B | MinRAM: 4 GB | Rating: ⭐⭐⭐⭐
        # BestFor  : Fast lightweight tasks; good quality for size
        # Notes    : ⬜ Superseded by 12B on PIPELINE; useful for quick automation
        @{ Id = 'gemma3:4b';         Enabled = $false; Name = 'Gemma 3 4B';           Provider = 'Google';    Url = 'https://ollama.com/library/gemma3' }

        # Gemma 2 9B | Size: 9B | MinRAM: 8 GB | Rating: ⭐⭐⭐⭐
        # BestFor  : Previous-gen Google open model; solid general chat
        # Notes    : ⬜ Use gemma3 variants instead — this is the prior generation
        @{ Id = 'gemma2';            Enabled = $false; Name = 'Gemma 2 9B';           Provider = 'Google';    Url = 'https://ollama.com/library/gemma2' }

        # =================================================================================
        # 🟠  ALIBABA — Qwen Family  (top multilingual + reasoning models)
        # =================================================================================
        # Qwen 2.5 14B | Size: 14B | MinRAM: 10 GB | Rating: ⭐⭐⭐⭐⭐
        # BestFor  : Reasoning, maths, coding, multilingual — best in class at this size
        # Notes    : ✅ Fully fits in RTX 5080 VRAM; highly recommended for coding + logic
        @{ Id = 'qwen2.5:14b';       Enabled = $true;  Name = 'Qwen 2.5 14B';         Provider = 'Alibaba';   Url = 'https://ollama.com/library/qwen2.5' }

        # Qwen 2.5 72B | Size: 72B | MinRAM: 40 GB | Rating: ⭐⭐⭐⭐⭐
        # BestFor  : Top-tier reasoning and coding; competes with frontier models
        # Notes    : ⬜ Partial GPU offload on RTX 5080; enable if you need maximum quality
        @{ Id = 'qwen2.5:72b';       Enabled = $false; Name = 'Qwen 2.5 72B';         Provider = 'Alibaba';   Url = 'https://ollama.com/library/qwen2.5' }

        # Qwen 2.5 7B | Size: 7B | MinRAM: 6 GB | Rating: ⭐⭐⭐⭐
        # BestFor  : Fast, efficient coding and chat
        # Notes    : ⬜ Superseded by qwen2.5:14b on PIPELINE
        @{ Id = 'qwen2.5:7b';        Enabled = $false; Name = 'Qwen 2.5 7B';          Provider = 'Alibaba';   Url = 'https://ollama.com/library/qwen2.5' }

        # QwQ 32B | Size: 32B | MinRAM: 22 GB | Rating: ⭐⭐⭐⭐⭐
        # BestFor  : Deep chain-of-thought reasoning; maths and science problems
        # Notes    : ⬜ Partial GPU offload; enable if you need extended reasoning tasks
        @{ Id = 'qwq';               Enabled = $false; Name = 'QwQ 32B';              Provider = 'Alibaba';   Url = 'https://ollama.com/library/qwq' }

        # =================================================================================
        # 🐋  DEEPSEEK — DeepSeek Family  (strong reasoning + coding from China)
        # =================================================================================
        # DeepSeek R1 14B | Size: 14B | MinRAM: 10 GB | Rating: ⭐⭐⭐⭐⭐
        # BestFor  : Chain-of-thought reasoning, maths, logic; shows full thinking process
        # Notes    : ✅ Fits in RTX 5080 VRAM; excellent for step-by-step reasoning tasks
        @{ Id = 'deepseek-r1:14b';   Enabled = $true;  Name = 'DeepSeek R1 14B';      Provider = 'DeepSeek';  Url = 'https://ollama.com/library/deepseek-r1' }

        # DeepSeek R1 70B | Size: 70B | MinRAM: 40 GB | Rating: ⭐⭐⭐⭐⭐
        # BestFor  : Top reasoning model; competes with o1 on benchmarks
        # Notes    : ⬜ Partial GPU offload; enable for heavy reasoning/research tasks
        @{ Id = 'deepseek-r1:70b';   Enabled = $false; Name = 'DeepSeek R1 70B';      Provider = 'DeepSeek';  Url = 'https://ollama.com/library/deepseek-r1' }

        # DeepSeek R1 8B | Size: 8B | MinRAM: 6 GB | Rating: ⭐⭐⭐⭐
        # BestFor  : Lightweight reasoning model; good quality for size
        # Notes    : ⬜ Superseded by r1:14b on PIPELINE
        @{ Id = 'deepseek-r1:8b';    Enabled = $false; Name = 'DeepSeek R1 8B';       Provider = 'DeepSeek';  Url = 'https://ollama.com/library/deepseek-r1' }

        # DeepSeek Coder V2 | Size: 16B | MinRAM: 12 GB | Rating: ⭐⭐⭐⭐⭐
        # BestFor  : Code generation and completion; strong across 300+ languages
        # Notes    : ⬜ Top coding specialist; enable alongside codellama for comparison
        @{ Id = 'deepseek-coder-v2'; Enabled = $false; Name = 'DeepSeek Coder V2 16B'; Provider = 'DeepSeek'; Url = 'https://ollama.com/library/deepseek-coder-v2' }

        # =================================================================================
        # 💻  CODE & DEVELOPMENT — Specialist Coding Models
        # =================================================================================
        # CodeLlama 13B | Size: 13B | MinRAM: 10 GB | Rating: ⭐⭐⭐⭐⭐
        # BestFor  : Code generation, completion, review — Meta's dedicated code model
        # Notes    : ✅ Fully GPU-accelerated on RTX 5080; best general-purpose code model
        @{ Id = 'codellama:13b';     Enabled = $true;  Name = 'CodeLlama 13B';        Provider = 'Meta';      Url = 'https://ollama.com/library/codellama' }

        # Qwen 2.5 Coder 14B | Size: 14B | MinRAM: 10 GB | Rating: ⭐⭐⭐⭐⭐
        # BestFor  : State-of-the-art code generation; top performer on coding benchmarks
        # Notes    : ✅ Best coding model on Ollama at this size; pairs well with codellama
        @{ Id = 'qwen2.5-coder:14b'; Enabled = $true;  Name = 'Qwen 2.5 Coder 14B';  Provider = 'Alibaba';   Url = 'https://ollama.com/library/qwen2.5-coder' }

        # CodeLlama 7B | Size: 7B | MinRAM: 6 GB | Rating: ⭐⭐⭐⭐
        # BestFor  : Fast code completion and generation
        # Notes    : ⬜ Superseded by codellama:13b on PIPELINE
        @{ Id = 'codellama';         Enabled = $false; Name = 'CodeLlama 7B';         Provider = 'Meta';      Url = 'https://ollama.com/library/codellama' }

        # StarCoder 2 7B | Size: 7B | MinRAM: 6 GB | Rating: ⭐⭐⭐⭐
        # BestFor  : Code completion; trained on 600+ programming languages
        # Notes    : ⬜ Broad language support; use qwen2.5-coder for quality, this for breadth
        @{ Id = 'starcoder2';        Enabled = $false; Name = 'StarCoder 2 7B';       Provider = 'BigCode';   Url = 'https://ollama.com/library/starcoder2' }

        # StarCoder 7B | Size: 7B | MinRAM: 6 GB | Rating: ⭐⭐⭐
        # BestFor  : Original StarCoder; code completion across many languages
        # Notes    : ⬜ Superseded by StarCoder 2 — kept for reference
        @{ Id = 'starcoder';         Enabled = $false; Name = 'StarCoder 7B';         Provider = 'BigCode';   Url = 'https://ollama.com/library/starcoder' }

        # =================================================================================
        # 💬  COHERE — Command Family  (strong RAG, tool use and enterprise chat)
        # =================================================================================
        # Command R+ 104B | Size: 104B | MinRAM: 64 GB | Rating: ⭐⭐⭐⭐⭐
        # BestFor  : RAG pipelines, tool use, enterprise Q&A, long-context reasoning
        # Notes    : ⬜ Exceeds PIPELINE RAM — requires quantization; strong for RAG use cases
        @{ Id = 'command-r-plus';    Enabled = $false; Name = 'Command R+ 104B';      Provider = 'Cohere';    Url = 'https://ollama.com/library/command-r-plus' }

        # Command R 35B | Size: 35B | MinRAM: 22 GB | Rating: ⭐⭐⭐⭐
        # BestFor  : RAG, tool use, retrieval-augmented tasks
        # Notes    : ⬜ Partial GPU offload on RTX 5080; good for RAG workflows
        @{ Id = 'command-r';         Enabled = $false; Name = 'Command R 35B';        Provider = 'Cohere';    Url = 'https://ollama.com/library/command-r' }

        # =================================================================================
        # 🦅  FALCON — TII Falcon Family  (legacy, strong benchmarks for its era)
        # =================================================================================
        # Falcon 7B | Size: 7B | MinRAM: 8 GB | Rating: ⭐⭐⭐
        # BestFor  : Fast general inference; legacy benchmark model
        # Notes    : ⬜ Outclassed by llama3.1 and mistral — kept for historical reference
        @{ Id = 'falcon';            Enabled = $false; Name = 'Falcon 7B';            Provider = 'TII';       Url = 'https://ollama.com/library/falcon' }

        # Falcon 40B | Size: 40B | MinRAM: 32 GB | Rating: ⭐⭐⭐
        # BestFor  : Heavy reasoning (legacy); was a top model in 2023
        # Notes    : ⬜ Outclassed by llama3.3 and qwen2.5:72b — kept for reference
        @{ Id = 'falcon:40b';        Enabled = $false; Name = 'Falcon 40B';           Provider = 'TII';       Url = 'https://ollama.com/library/falcon' }

        # =================================================================================
        # ⚡  QUANTIZED / CPU-OPTIMIZED — GGUF Builds for Low-Power Machines
        # =================================================================================
        # Llama 3.1 8B Q4 | Size: 8B | Quantized: Q4_K_M | MinRAM: 5 GB | Rating: ⭐⭐⭐⭐
        # BestFor  : CPU-only machines or tight VRAM; near full-precision quality
        # Notes    : ⬜ Not needed on PIPELINE — use full precision llama3.1 instead
        @{ Id = 'llama3.1:8b-q4_K_M'; Enabled = $false; Name = 'Llama 3.1 8B (Q4 Quantized)'; Provider = 'Meta'; Url = 'https://ollama.com/library/llama3.1' }

        # Mistral 7B Q4 | Size: 7B | Quantized: Q4_K_M | MinRAM: 5 GB | Rating: ⭐⭐⭐⭐
        # BestFor  : CPU-only machines; fast Mistral inference without GPU
        # Notes    : ⬜ Not needed on PIPELINE — use full precision mistral instead
        @{ Id = 'mistral:7b-q4_K_M'; Enabled = $false; Name = 'Mistral 7B (Q4 Quantized)'; Provider = 'Mistral AI'; Url = 'https://ollama.com/library/mistral' }

        # Llama 2 7B Q4 | Size: 7B | Quantized: Q4_0 | MinRAM: 4 GB | Rating: ⭐⭐⭐
        # BestFor  : Very low RAM machines (legacy)
        # Notes    : ⬜ Legacy model — use quantized llama3.1 instead
        @{ Id = 'llama2:7b-q4_0';    Enabled = $false; Name = 'Llama 2 7B (Q4 Quantized)'; Provider = 'Meta';  Url = 'https://ollama.com/library/llama2' }
    )
}

# -------------------------------------------------------------------------------------------------

if ($Global.Log.Enabled) {
    Write-Header "`$Ollama` Variable:"
    $Ollama | Format-List
}
