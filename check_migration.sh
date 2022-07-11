while true; do
    if [ $(docker inspect coffee_migration_job_1 --format='{{.State.Status}}') == "exited" ]; then
        echo $(docker inspect coffee_migration_job_1 --format='{{.State.Status}}')
        break
    fi
    done

echo $(docker inspect coffee_migration_job_1 --format='{{.State.ExitCode}}')
exit $(docker inspect coffee_migration_job_1 --format='{{.State.ExitCode}}')