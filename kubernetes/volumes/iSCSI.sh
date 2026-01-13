# Install open-iscsi package
sudo apt-get update
sudo apt-get install -y open-iscsi

# Enable and start the service
sudo systemctl enable iscsid
sudo systemctl start iscsid

# Verify it's running
sudo systemctl status iscsid

# Also start open-iscsi service
sudo systemctl enable open-iscsi
sudo systemctl start open-iscsi
