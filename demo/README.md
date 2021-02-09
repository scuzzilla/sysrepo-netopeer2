### Simulation - Main Stpes:

#### Generic intro on sysrepo/netopeer2
store schemas/data ...

#### 0 - Collect schemas directly from the network
```
  shell# nc_schemas_extract.sh -f <devices.lst> 
```

#### 1 - Get the full config from the PE
```
  shell#  netconf-console --host 10.110.110.65 --port 830 -u daisy -p daisy --get-config
```

#### 2 - Extract the schemas related to the overaly configuration
#### 3 - load the extracted schemas into sysrepo
#### 4 - change the schemas permissions
#### 5 - Validate/Import the associated configuration (XML) into sysrepo
#### 6 - tests with xpath & sysrepo
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
