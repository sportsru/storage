#!/bin/sh

lockfile='lockfile'

if [ -f $lockfile ]
then
    echo Deploy is locked, wait for current operation to finish.
    exit
fi

uploadservers="fe1"
staticservers="fe1 fe2"
staticproject='Static'
sshservers="fe1 fe2 be7 be12 be14 be16 be18 be20 be25"
app_path=/home/unigrid/node/
git_path=svn+ssh://sports@svn.in.sports.ru/services/trunk

symlink_name=services
svncom=svn

sshcom=ssh
sshuser=unigrid

maxrev_count=5

# END

command=$1
project=$2
revision=$3

up() {
	for check in `ls .`; do
		if [ $project == $check ]; then
			touch $lockfile
    	    cd $project
    	    # old=`svnversion`
    	    #if [ $revision > 0 ]; then
    	    #    svn up -r$revision
    	    #else
    	    git pull
    	    #fi
    	    cd -
    	    echo ""
    	    #echo "Previous deployed revision of" $project":"
    	    #echo $old
    	    echo "Finished. Use './deploy.sh sync' to deploy changes"
    	    echo ""
    	    rm $lockfile
    	    exit
    	fi
    done
    echo "Project" $project "not found"
}

print_help() {
	echo ""
    echo "Utility that deploys an application on the remote servers."
    echo "Usage: "
    echo "./deploy.sh up <Project> [revision]"
    echo "./deploy.sh sync"
    echo ""
    echo "up          - SVN UP project to latest revision, or certain revision number if given"
    echo "sync        - sync files to other backends"
    echo ""
}

get_ssh_connect() {
    server=$1
    port=`echo $server|awk -F : '{if (NF==2) print $NF}'`
    server_port=`echo $server|awk -F : '{if (NF==2) print $1}'`
    if [ ${port:-no} != no -a ${server_port:-no} != no ]; then
        echo "${sshcom} -p ${port} ${sshuser}@${server_port}"
    else
        echo "${sshcom} ${sshuser}@${server}"
    fi
}

sync() {
	touch $lockfile
	if [ "$project" == "$staticproject" ]; then
		servers=$staticservers
	else
		servers=$sshservers
	fi

	for server in $servers; do
		for ignore in $uploadservers; do
			if [ $server != $ignore ]; then
				echo "Sync to" $server
				rsync -hz -rlptoD --stats --super --delete ${app_path} $server:${app_path}
			fi
		done

		if [ "$project" != "$staticproject" ]; then
			sshstr=`get_ssh_connect $server`
			execstr="${sshstr} sudo /etc/init.d/php-fcgi stop && sleep 2 && sudo /etc/init.d/php-fcgi start"
	        echo "Restart php on" $server
	        echo "$execstr" 1>&2
	        echo `$execstr`
	        echo "Done."
	    fi
        echo ""
	done
	rm $lockfile
	echo ""
}

case $command in
	sync)
		sync
	;;

	up)
    	up
    ;;

	*)
		print_help
	;;
esac

