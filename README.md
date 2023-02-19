```bash
kubectl apply -f https://raw.githubusercontent.com/prometheus-community/helm-charts/main/charts/kube-prometheus-stack/crds/crd-servicemonitors.yaml
helm dependency build bootstrap/argo-cd
kubectl create namespace argocd
kubectl create secret generic helm-secrets-private-keys --from-file=key.asc=/home/ajgon/.config/sops/age/keys.txt -n argocd
helm secrets install argocd bootstrap/argo-cd --namespace argocd -f projects/default/secrets.yaml
kubectl apply -f https://raw.githubusercontent.com/ajgon/home-ops/master/bootstrap/apps/argo-cd.yaml
```
