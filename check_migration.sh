while true; do
    if [ $(docker inspect minter-guru-$1-migration-job-1 --format='{{.State.Status}}') == "exited" ]; then
        echo $(docker inspect minter-guru-$1-migration-job-1 --format='{{.State.Status}}')
        break
    fi
    done

echo $(docker inspect minter-guru-$1-migration-job-1 --format='{{.State.ExitCode}}')
exit $(docker inspect minter-guru-$1-migration-job-1 --format='{{.State.ExitCode}}')