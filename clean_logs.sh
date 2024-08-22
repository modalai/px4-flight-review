set -e -x
find ./data/log_files/ -mtime +30 | sudo xargs rm
