#!/usr/bin/env bash

result="0"

for app in "$@"; do
  chart_dir="$(yq '.spec.source.path' "${app}")"
  namespace="$(yq '.spec.destination.namespace' "${app}")"
  values_file="$(mktemp)"
  k8s_version="1.26.1"
  cfg="${chart_dir}/.datree.yaml"

  [ ! -d "${chart_dir}" ] && continue
  [ "$(yq '.ignore' "${cfg}")" = "true" ] && continue

  echo -e "\e[0;36m>>\n>> 🗃️ Processing file: ${app}\n>>\e[0m\n"

  # build values file
  yq '.spec.source.helm.values' "${app}" > "${values_file}"

  # build policy file
  skip_rules="$(yq '.skip_rules | join("|")' "${cfg}")"
  if [ -z "${skip_rules}" ]; then
    policy_file="scripts/datree-default-policy.yaml"
  else
    policy_file="$(mktemp)"
    yq "del( .policies.[].rules.[] | select(.identifier | test(\"${skip_rules}\") ) )" scripts/datree-default-policy.yaml > "${policy_file}"
  fi

  yq="$(yq '.filter_resources' "${cfg}" | grep -v '^null$')"
  helm secrets template "${chart_dir}" --namespace "${namespace}" -f projects/default/secrets.yaml -f "${values_file}" | yq "${yq}" | datree test - --schema-version "${k8s_version}" --no-record --policy-config "${policy_file}"
  result="$(("${result}" + $?))"

  rm -rf "${values_file}"
done

exit $result
