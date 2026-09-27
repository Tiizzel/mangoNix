# NixOS Package & Documentation Research Guidelines

When researching NixOS packages, options, configurations, and documentation:

1. **`mcp-nixos` MCP Server**:
   - Always query the `mcp-nixos` MCP server (`call_mcp_tool` with `ServerName: "mcp-nixos"`, `ToolName: "nix"` or `ToolName: "nix_versions"`) for package lookups, version history, NixOS/Home-Manager options, and documentation checks.

2. **Package Search**:
   - Always search and verify packages across:
     - **MyNixOS**: https://mynixos.com/
     - **NixOS Search (Unstable)**: https://search.nixos.org/packages?channel=unstable
   - Always cross-reference with other sources as well (e.g., upstream repositories, Nixpkgs pull requests/issues, Repology).

3. **Documentation**:
   - Always consult the official **NixOS Wiki**: https://wiki.nixos.org/wiki/NixOS_Wiki for any documentation, service configuration, and hardware guidelines.
   - Always cross-reference with other sources as well (e.g., https://nix.dev, the official NixOS manual, Home Manager appendices, Arch Wiki, and upstream projects).
