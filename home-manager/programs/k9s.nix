{ config, pkgs, lib, inputs, ... }:

{
  programs.k9s = {
    enable = true;

    plugins = {
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
}
