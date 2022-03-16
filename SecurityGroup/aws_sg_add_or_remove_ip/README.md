# Upload file or folder to remote bucket

#### The folowing script requires 3 arguments `add` or `remove`, `Security group name`, `prod` or `nonprod` environment name. Database file `ip_prod.txt` will be used for `prod` and `ip_nonprod.txt` will be used for `nonprod` environment. Script will syncronize local IP database to the remote Security group. If IP address will be present in Security group and not present in the local file it will be deleted

```bash
$ ./add_remove_ip_from_sg.sh add/remove security_group_name prod/nonprod
```
