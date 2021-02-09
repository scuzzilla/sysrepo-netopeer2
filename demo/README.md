### Simulation - Main Stpes:

#### Generic intro on sysrepo/netopeer2
![alt text](https://www.sysrepo.org/diagram.png "sysrepo")

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

#### 5 - Validate/Import the associated configuration (XML) into sysrepo
```
  shell# sysrepocfg --import=10.110.110.65_hostname.xml --datastore startup --module Cisco-IOS-XE-native   
  shell# sysrepocfg --import=10.110.110.66_hostname.xml --datastore startup --module Cisco-IOS-XE-native   
```

#### 6 - tests with xpath & sysrepo
```
  shell# sysrepocfg --export --xpath '/Cisco-IOS-XE-native:native/hostname' --datastore startup
```

#### 7 - tests with netopeer2, netconf client/server & sysrepo

---

### Simulation - Future steps

#### 0 - ...
#### 1 - ... 

---

### References

- https://github.com/YangModels/yang
- https://yangcatalog.org/
- https://github.com/sysrepo/sysrepo-python
- https://github.com/CESNET/libyang-python
- https://github.com/sysrepo/sysrepo
- https://www.sysrepo.org/documentation
- https://netopeer.liberouter.org/doc/sysrepo/master/html/sysrepocfg.html
- https://github.com/CESNET/netopeer2
- https://kea.readthedocs.io/en/kea-1.6.3/arm/netconf.html#overview
- https://kb.isc.org/docs/building-a-kea-testbed-with-netconf
