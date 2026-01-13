# Update the deployment with correct context path
kubectl patch deployment linkding -n logging -p '{"spec":{"template":{"spec":{"containers":[{"name":"linkding","env":[{"name":"LD_CONTEXT_PATH","value":""}]}]}}}}'

# Wait for the new pod to start
kubectl rollout status deployment/linkding -n logging

# Then try accessing again
echo "Try: http://192.168.43.127:8080"


after deployment i can add a user with the following ::::

# Update deployment with superuser credentials
kubectl patch deployment linkding -n logging -p '{"spec":{"template":{"spec":{"containers":[{"name":"linkding","env":[{"name":"LD_SUPERUSER_NAME","value":"admin"},{"name":"LD_SUPERUSER_PASSWORD","value":"admin123"}]}]}}}}'

# Wait for restart
kubectl rollout status deployment/linkding -n logging

# Then try to login at:
echo "Try logging in at: http://192.168.43.127:8080/accounts/login/"
echo "Username: admin"
echo "Password: admin123"