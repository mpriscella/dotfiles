{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  programs.k9s = {
    enable = true;

    plugins = {
      debug-pod = {
        shortCut = "Shift-D";
        description = "Add debug pod";
        dangerous = false;
        scopes = ["namespaces"];
        command = "bash";
        background = false;
        confirm = true;
        args = [
          "-c"
          "kubectl run -it $(echo $KUBECONFIG | md5sum | awk '{print $1}') --namespace $NAME --image=ubuntu --rm=true --restart=Never -- bash"
        ];
      };

      debug-container = {
        shortCut = "d";
        description = "Add debug container";
        dangerous = true;
        scopes = ["containers"];
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
