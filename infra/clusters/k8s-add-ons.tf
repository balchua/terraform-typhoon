resource "null_resource" "install_addons" {
  depends_on = ["module.digital-ocean-btc"]

  provisioner "local-exec" {
    command = <<EOT

      export KUBECONFIG="${var.do_kubeconfig}"
      until kubectl get nodes 2>/dev/null; do printf '.' ; sleep 20; done
      until kubectl apply -f ../../nginx-ingress/digital-ocean/0-namespace.yaml 2>/dev/null; do printf '.' ; sleep 5; done
      until kubectl apply -f ../../nginx-ingress/digital-ocean/rbac/sa.yaml 2>/dev/null; do printf '.' ; sleep 5; done
      until kubectl apply -f ../../nginx-ingress/digital-ocean/rbac/cluster-role.yaml 2>/dev/null; do printf '.' ; sleep 5; done
      until kubectl apply -f ../../nginx-ingress/digital-ocean/rbac/cluster-role-binding.yaml 2>/dev/null; do printf '.' ; sleep 5; done
      until kubectl apply -f ../../nginx-ingress/digital-ocean/rbac/role.yaml 2>/dev/null; do printf '.' ; sleep 5; done
      until kubectl apply -f ../../nginx-ingress/digital-ocean/rbac/role-binding.yaml 2>/dev/null; do printf '.' ; sleep 5; done
      until kubectl apply -f ../../nginx-ingress/digital-ocean/daemonset.yaml 2>/dev/null; do printf '.' ; sleep 5; done
      until kubectl apply -f ../../nginx-ingress/digital-ocean/service.yaml 2>/dev/null; do printf '.' ; sleep 5; done
      #prometheus addons
      until kubectl apply -R -f ../../prometheus/ 2>/dev/null; do printf '.' ; sleep 5; done
      #Grafana addons
      until kubectl apply -f ../../grafana/ 2>/dev/null; do printf '.' ; sleep 5; done

EOT
  }
}

