#!/usr/bin/env bash
SSH_USER=jenkins
SSH_PASS=jenkins
SSH_GW=172.17.0.1
TMP_FILE=/tmp/reverse_ssh_tunnel.txt
SSH_DURATION=1800
SSH_MSG="\n#####################################################################\n SSH into this build environment with the command below.\n The session will remain open for $SSH_DURATION seconds. Password is $SSH_PASS.\n#####################################################################\n"

function start_sshd {
	sudo /usr/sbin/sshd
	if [ $? != 0 ]
	then
		echo "Error: Could not start SSHD, remote access unavailable."
		return 1
	fi
	return 0
}

function create_tunnel {
	ssh -f -N -R:0:127.0.0.1:22 -i /home/jenkins/.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $SSH_USER@$SSH_GW 2> $TMP_FILE 
	if [ $? != 0 ]
	then
		echo "Error: Could not create tunnel to gateway host, remote access unavailable."
		return 2
	fi

	sleep 1
	grep 'Allocated port' $TMP_FILE | awk -F' ' -v ssh_msg="$SSH_MSG" -v ssh_user="$SSH_USER" -v ssh_gw="$SSH_GW" '{ print ssh_msg, "\n ssh -p", $3, ssh_user "@" ssh_gw, "\n" }' 
	return 0


}

start_sshd && create_tunnel && sleep $SSH_DURATION
if [$? != 0 ]
then
        echo "Closing session"
else
        echo "Time's up! Bye."
fi
exit 0
