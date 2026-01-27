{
  description = "Helm charts development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # Helm v3
            kubernetes-helm

            # Chart testing tool (ct)
            chart-testing

            # Python (required by chart-testing)
            python3

            # Useful for local testing
            kubectl
            kind
          ];
        };
      }
    );
}
