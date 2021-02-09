### Simulation - Main Stpes:

#### Generic intro on sysrepo/netopeer2
![alt text](https://www.sysrepo.org/diagram.png "sysrepo")

- IPC (Inter-process communication) between sysrepo & sysrepo-tools (sysrepoctl, sysrepocfg)
- IPC between sysrepo (sysrepo-plugind) & C/Python API (sysrepo, libyang)
- IPC between sysrepo & netopeer2 (netconf server)

Netopeer2 can be used to enable a remote interaction with sysrepo via netconf protocol.
Remote operations on sysrepo could be also acheived developing ad-hoc plugins using both sysrepo & libyang API.

---

#### 0 - Extract schemas directly from the network
```
  shell# nc_schemas_extract.sh -f <devices.lst> 
```
Remember to sanitize the exported schemas:
```
  shell#: sed -i /\&gt;/\>/g *
  shell#: sed -i /\&lt;/\</g *
  shell#: sed -i /\&amp;/\&/g *
```

#### 1 - Get the full config from the PE
```
  shell#  netconf-console --host 10.110.110.65 --port 830 -u daisy -p daisy --get-config > 10.110.110.65_full.xml
  shell#  egrep 'xmlns' 10.110.110.65_full.xml | awk -F "\"" '{print $2}' | sort | uniq
```

#### 2 - Extract the schemas related to the overaly configuration
```
  shell#  egrep 'xmlns' 10.110.110.65_full.xml | awk -F "\"" '{print $2}' | sort | uniq
```

#### 3 - load the extracted schemas into sysrepo
```
  shell# sysrepoctl -i Cisco-IOS-XE-isis.yang  -s '/home/toto/Projects/sysrepo-netopeer2/tools/nc_schemas_extract/capabilities_yangs/10.110.110.65/'
  shell# sysrepoctl -i Cisco-IOS-XE-mpls.yang  -s '/home/toto/Projects/sysrepo-netopeer2/tools/nc_schemas_extract/capabilities_yangs/10.110.110.65/'
  shell# sysrepoctl -i Cisco-IOS-XE-bgp.yang  -s '/home/toto/Projects/sysrepo-netopeer2/tools/nc_schemas_extract/capabilities_yangs/10.110.110.65/'
  shell# sysrepoctl -i Cisco-IOS-XE-route-map.yang  -s '/home/toto/Projects/sysrepo-netopeer2/tools/nc_schemas_extract/capabilities_yangs/10.110.110.65/'
```
to be able to verify the imported schemas:
```
  shell: sysrepocfg -l
```

#### 4 - change the schemas permissions
```
  shell# sysrepoctl --change <module> --owner <owner> --group <group> --permissions <unix-bit-mask>
```

#### 5 - Validate/Import/Edit the associated configuration (XML) into sysrepo
```
  shell# sysrepocfg --import=10.110.110.65_hostname.xml --datastore startup --module Cisco-IOS-XE-native   
  shell# sysrepocfg --import=10.110.110.66_hostname.xml --datastore startup --module Cisco-IOS-XE-native   
```
to be able to edit the configuration directly from the datastore
```
  shell# doas sysrepocfg --edit=vim --lock --datastore startup
```

#### 6 - tests with xpath & sysrepo
```
  shell# sysrepocfg --export --xpath '/Cisco-IOS-XE-native:native/hostname' --datastore startup
```

#### 7 - tests with netopeer2, netconf client/server & sysrepo
Assuming that netopeer2-server is up & running, netopeer2-cli is used to perform operations on sysrepo via netconf
```
+toto@sysrepo02 ~ $ netopeer2-cli
> connect
Interactive SSH Authentication
Type your password:
Password: ***
>help
Available commands:
...
status          Display information about the current NETCONF session
connect         Connect to a NETCONF server
commit          ietf-netconf <commit> operation
copy-config     ietf-netconf <copy-config> operation
delete-config   ietf-netconf <delete-config> operation
get-config      ietf-netconf <get-config> operation
lock            ietf-netconf <lock> operation
unlock          ietf-netconf <unlock> operation
validate        ietf-netconf <validate> operation
subscribe       notifications <create-subscription> operation
get-schema      ietf-netconf-monitoring <get-schema> operation
get-data        ietf-netconf-nmda <get-data> operation
edit-data       ietf-netconf-nmda <edit-data> operation
?               Display commands description
exit            Quit the program

> get-config --source startup --filter-xpath '/Cisco-IOS-XE-native:native'
DATA
<native xmlns="http://cisco.com/ns/yang/Cisco-IOS-XE-native">
	<hostname>PE1</hostname>
</native>
```
---

### Simulation - Future steps:

- Automate sysrepo schemas/data manipulation using both sysrepo & libyang API
- Integrate sysrepo with NetLabs to be able to interact with the network devices

---

### References:

- YANG schemas official git repo - https://github.com/YangModels/yang
- YANG schemas discovery - https://yangcatalog.org/
- Sysrepo API doc - https://github.com/sysrepo/sysrepo-python
- Libyang API doc - https://github.com/CESNET/libyang-python
- Sysrepo source code - https://github.com/sysrepo/sysrepo
- Netopeer2 source code - https://github.com/CESNET/netopeer2
- Sysrepo doc - https://www.sysrepo.org/documentation
