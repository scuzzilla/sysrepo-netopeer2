# sysrepo-netopeer2
exploring sysrepo/netopeer2 functionalities &amp; python bindings

### sysrepoctl
- listing the installed schemas:
```
sysrepoctl -l|--list
```
- installing a new schema:
```
sysrepoctl -i|--install <path>
```


It is a utility that enables changing schemas (modules). Specifically, it can list, install, uninstall, or update them. 
Also, features, replay support, and permissions of a module can be changed. 
It is important to keep in mind what operations are performed immediatelly and what are postponed (details in schemas).
-l, --list

All currently installed modules are listed in a concise table with basic information about them. There is also information about any prepared changes.
sysrepoctl --list
-i, --install <path>

YANG modules are installed simply by specifying the path to them in either YANG or YIN format.
sysrepoctl --install ~/Documents/modules/ietf-interfaces.yang
-u, --uninstall <module>

To remove a YANG module, its name (not file name) must be specified. All installed modules that can be removed are printed by --list.
sysrepoctl --uninstall ietf-interfaces
-c, --change <module>

Installed modules can be changed in several ways, optionally combined into one command. Firstly, their YANG features can be modified.
sysrepoctl --change ietf-interfaces --(disable|enable)-feature if-mib

Then, their replay support (storing received notifications) can be turned on or off.
sysrepoctl --change ietf-interfaces --replay on

Finally, file system permissions can be adjusted.
sysrepoctl --change ietf-interfaces --owner netconf --group netconf --permissions 660
-U, --update <path>

Existing installed YANG modules can be updated to newer revision.
sysrepoctl --update ~/Documents/modules/ietf-netconf@2013-09-29.yang
-C, --connection-count

Get the number of currently connected clients. Can be used to check whether some schema changes can be immediately applied (if there are no connections) or not.
sysrepoctl --connection-count


### sysreopcfg



