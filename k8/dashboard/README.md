# Deploys k8 dahsboard 

`kubectl create -f dashboard.admin-user.yml -f dashboard.admin-user-role.yml`


## Get token

`kubectl -n kubernetes-dashboard describe secret admin-user-token | grep ^token`

## Proxy

`kubectl proxy`

http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

