function k8s_podname {
  ns=$1; shift
  selector="$@"
  name=$(kubectl -n ${ns} get pods ${selector} -o=jsonpath="{.items[0].metadata.name}")
  echo ${name}
}

function k8s_igpf {
  ns=${1}; shift
  port=${1}; shift
  selector="$@"
  kubectl -n ${ns} port-forward --address 0.0.0.0 $(k8s_podname ${ns} ${selector}) ${port}
}

# This function is used to get the password of admin user of jenkins,
# which is deployed by helm: https://github.com/helm/charts/tree/master/stable/jenkins
function k8s_jenkins_password {
  ns=${1}; shift
  echo $(kubectl get secret jenkins -n ${ns} -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode)
}
