resource "null_resource" "install_addons" {
  depends_on = [
    "module.digital-ocean-btc"]

  provisioner "local-exec" {
    command = <<EOT

      export KUBECONFIG="${var.do_kubeconfig}"
      until kubectl get nodes 2>/dev/null; do printf '.' ; sleep 5; done
      until kubectl apply -f ../../nginx-ingress/digital-ocean/namespace.yaml 2>/dev/null; do printf '.' ; sleep 5; done
      until kubectl apply -f ../../nginx-ingress/digital-ocean/rbac/sa.yaml 2>/dev/null; do printf '.' ; sleep 5; done
      until kubectl apply -f ../../nginx-ingress/digital-ocean/rbac/cluster-role.yaml 2>/dev/null; do printf '.' ; sleep 5; done
      until kubectl apply -f ../../nginx-ingress/digital-ocean/rbac/cluster-role-binding.yaml 2>/dev/null; do printf '.' ; sleep 5; done
      until kubectl apply -f ../../nginx-ingress/digital-ocean/rbac/role.yaml 2>/dev/null; do printf '.' ; sleep 5; done
      until kubectl apply -f ../../nginx-ingress/digital-ocean/rbac/role-binding.yaml 2>/dev/null; do printf '.' ; sleep 5; done
      until kubectl apply -f ../../nginx-ingress/digital-ocean/default-backend/deployment.yaml 2>/dev/null; do printf '.' ; sleep 5; done
      until kubectl apply -f ../../nginx-ingress/digital-ocean/default-backend/service.yaml 2>/dev/null; do printf '.' ; sleep 5; done
      until kubectl apply -f ../../nginx-ingress/digital-ocean/daemonset.yaml 2>/dev/null; do printf '.' ; sleep 5; done
      until kubectl apply -f ../../nginx-ingress/digital-ocean/service.yaml 2>/dev/null; do printf '.' ; sleep 5; done
EOT
  }
}
