{ config, pkgs, lib, inputs, ... }:

{
  config = {
    # https://github.com/nix-community/home-manager/blob/master/modules/programs/k9s.nix
    programs.k9s = {
      enable = true;

      plugin = {
        debug-container = {
          shortCut = "d";
          description = "Add debug container";
          dangerous = true;
          scopes = [ "containers" ];
          command = "bash";
          background = false;
          confirm = true;
          args = [
            "-c"
            "kubectl debug -it --context $CONTEXT --namespace $NAMESPACE $POD --target=$NAME --image=ubuntu --share-processes -- bash"
          ];
        };
      };
    };
  };
}
