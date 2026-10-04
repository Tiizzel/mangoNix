{ inputs, ... }: {
  flake.aspects.base.nixos =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      # Ollama — Local LLM inference server (systemd service)
      services.ollama = {
        enable = false;
        # Use Vulkan for broad AMD GPU acceleration (ROCm also works but
        # is heavier — switch to pkgs.ollama-vulkan if you need full
        # compute-grade throughput on your AMD card).
        package = pkgs.ollama-rocm;

        # Pre-pull a lightweight model so you can test right after rebuild.
        # Add more from https://ollama.com/library as needed.
        loadModels = [
          "ornith:9b"
          "qwen3.8:27b"
        ];

        # Declarative model management — removes models not listed above.
        syncModels = true;
      };
    };
}
