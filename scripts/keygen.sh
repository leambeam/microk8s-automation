# Generate two keypairs without passphrases
ssh-keygen -t rsa -f keys/ubuntu_key -N "" -C "Ubuntu VM Key"
ssh-keygen -t rsa -f keys/rocky_key -N "" -C "Rocky VM Key"

# If you do not want to write to private key files switch permissions to 400
chmod 600 keys/ubuntu_key
chmod 600 keys/rocky_key

chmod 644 keys/ubuntu_key.pub
chmod 644 keys/rocky_key.pub