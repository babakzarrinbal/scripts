#!/bin/bash

# Function to list pods with additional columns
list_pods() {
  kubectl get pods --no-headers -o custom-columns="NAME:.metadata.name,READY:.status.containerStatuses[*].ready,STATUS:.status.phase,RESTARTS:.status.containerStatuses[*].restartCount,AGE:.metadata.creationTimestamp"
}

while true; do
  # Get the list of pods
  pods=$(list_pods)

  # Use fzf to select a pod with a timeout for 2 seconds to refresh the list
  selected_pod=$(echo "$pods" | fzf --prompt="Select a pod: " --header="NAME                               READY   STATUS    RESTARTS   AGE" --preview="echo {}" --preview-window=down:3:wrap)

  # Check if fzf was interrupted (esc pressed)
  if [ $? -ne 0 ]; then
    break
  fi

  # If no pod is selected, continue to refresh the list
  if [ -z "$selected_pod" ]; then
    sleep 2
    continue
  fi

  # Extract the selected pod name
  selected_pod_name=$(echo "$selected_pod" | awk '{print $1}')

  # If a pod is selected, show menu for actions
  action=$(echo -e "Logs\nExec\nDelete" | fzf --prompt="Select an action for $selected_pod_name: ")

  if [ "$action" == "Logs" ]; then
    kubectl logs "$selected_pod_name" -f --all-containers=true
  elif [ "$action" == "Exec" ]; then
    kubectl exec -it "$selected_pod_name" -- sh
  elif [ "$action" == "Delete" ]; then
    confirm=$(echo -e "Yes\nNo" | fzf --prompt="Are you sure you want to delete pod $selected_pod_name forcefully? (y/n): ")
    if [ "$confirm" == "Yes" ]; then
      kubectl delete pod "$selected_pod_name" --grace-period=0 --force
    else
      echo "Deletion cancelled."
    fi
  else
    echo "Invalid action selected."
  fi

done
