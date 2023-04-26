# sysrepo-netopeer2
exploring sysrepo/netopeer2 functionalities &amp; python bindings

### sysrepoctl
- listing the installed schemas:
```
sysrepoctl -l|--list
```
- installing a new schema:
```
sysrepoctl -i|--install <module-path> -s <search-path>
```
- uninstall an existing schema:
```
sysrepoctl -u|--uninstall <module-path>
```
- modify schema options
```
sysreopctl -c|--change <module-path>

sysrepoctl --change ietf-interfaces --(disable|enable)-feature if-mib
sysrepoctl --change ietf-interfaces --replay on
sysrepoctl --change ietf-interfaces --owner netconf --group netconf --permissions 660
```
- update schema
```
sysreopctl -U|--update <module-path>
```
- concurrent connections count
```
sysrepoctl --connection-count
```

---

### sysreo
https://github.com/sysrepo/sysrepo
