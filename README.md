```bash
kubectl apply -f https://raw.githubusercontent.com/prometheus-community/helm-charts/main/charts/kube-prometheus-stack/crds/crd-servicemonitors.yaml
kubectl apply -f https://raw.githubusercontent.com/prometheus-community/helm-charts/main/charts/kube-prometheus-stack/crds/crd-prometheusrules.yaml
helm dependency build bootstrap/redis-ha
helm secrets install redis-ha bootstrap/redis-ha --namespace storage --create-namespace -f projects/default/secrets.yaml
kubectl create namespace argocd
kubectl create secret generic helm-secrets-private-keys --from-file=key.asc=$HOME/.config/sops/age/keys.txt -n argocd
helm dependency build bootstrap/argo-cd
helm secrets install argocd bootstrap/argo-cd --namespace argocd -f projects/default/secrets.yaml
kubectl apply -f https://raw.githubusercontent.com/ajgon/home-ops/master/bootstrap/apps/argocd.yaml
kubectl apply -f https://raw.githubusercontent.com/ajgon/home-ops/master/bootstrap/apps/app-of-apps.yaml
```
