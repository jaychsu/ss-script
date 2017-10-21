SS Script
======

## Quick Start - Server Side:

1. run script [test-speed-vultr.rb](./test-speed-vultr.rb) to check speed.
2. visit [vultr](https://www.vultr.com).
3. create an instance with button `Deploy New Server` with options:

    ```
    Server Location:  the node chosen in (1)
    Server Type:  centos 7 x64
    Other:  just keep as default if nothing need
    ```

4. `ssh root@instance-ip`, the login info for instance is in server details.
5. `git clone` or `scp` this repo to server instance.
6. run `bash ss-init-centos.sh` and enter the question.
7. done.

## Quick Start - Client Side:

### Config in Surge

Just add record into config:

```
vultr = custom, {SVR_IP}, {SVR_PORT}, aes-256-cfb, {SVR_PWD}, http://cat-cdn.oss-cn-shenzhen.aliyuncs.com/SSEncrypt.module
```

p.s. {SVR_IP}, {SVR_PORT}, and {SVR_PWD} are the params you inputted during the script [ss-init-centos.sh](./ss-init-centos.sh) running.
