{...}: {
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

      # SSM session onto the EC2 instance backing the selected node. Resolves
      # the AWS profile from the kubeconfig context's exec env, then maps the
      # node's private DNS name to an instance ID.
      ssm-node = {
        shortCut = "s";
        description = "Start SSM Session";
        dangerous = true;
        scopes = ["nodes"];
        command = "bash";
        background = false;
        confirm = true;
        args = [
          "-c"
          ''user=$(kubectl config view -o jsonpath="{.contexts[?(@.name == \"$CONTEXT\")].context.user}"); profile=$(kubectl config view -o jsonpath="{.users[?(@.name == \"$user\")].user.exec.env[0].value}"); instance_id=$(aws ec2 describe-instances --profile "$profile" --filters "Name=private-dns-name,Values=$NAME" --query "Reservations[*].Instances[*].InstanceId" --output text); aws ssm start-session --profile "$profile" --target "$instance_id"''
        ];
      };
    };
  };
}
