#starting server in listening mode

```shell
$ oc rsh sctpserver
sh-4.2# nc -l 30102 --sctp
```

#client side

```shell
$ oc rsh sctpclient
sh-4.2# nc -v 10.129.2.31 30102 --sctp
Ncat: Version 7.50 ( https://nmap.org/ncat )
```




