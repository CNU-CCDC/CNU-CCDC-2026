# Making sure the script is running as the root user
if [ $EUID -ne 0 ]; then
  echo "This script requires root permissions.  Please rerun under the root user or with the sudo command"
  exit 1
fi

# Getting active SSH connections
ssh_connections=$(ss -ptn | awk '{ print }' | sed -n '/users:(("ssh"/p')

# Handling if there are no open connections
if [ -z "$ssh_connections" ]; then
    echo "There are no active ssh connections"
    exit
fi

# Printing info for each connection
echo "SSH connections:"
saved_IFS=$IFS; IFS='\n'
for conn in $ssh_connections; do
    # Getting the server the process is connected to
    full_server=$(echo "$conn" | awk '{ print $5 }')
    server_ip=$(echo "$full_server" | awk -F: '{ print $1 }')
    server_port=$(echo "$full_server" | awk -F: '{ print $2 }')

    # Getting the PID of the connection
    pid=$(echo "$conn" | awk -F, '{ print $2 }' | sed 's/pid=//')

    # Logging the active connections
    echo "Connected to ${server_ip} on port ${server_port} with PID ${pid}"
done
IFS=$saved_IFS
