# Adding Traefik

https://github.com/traefik/traefik-helm-chart

Why did we disable traefik just to install it later? Currently k3s uses version 1.7 so this should get us the latest and greatest

Install
```
helm repo add traefik https://helm.traefik.io/traefik
helm repo update
helm install traefik traefik/traefik
```

Deploy dashboard

`kubectl apply -f dashboard.yaml`
