# NSC3 Network Diagnostics Toolkit (Linux)

This toolkit provides a simple, self-contained way to validate network connectivity
from on-premise network segments to the SaaS platform.
Two versions are included:
- Linux diagnostics
- Windows diagnostics

Both versions run fully offline and produce a detailed log file.

## 1. What the tool checks

1. DNS resolution  
2. HTTPS reachability (port 443)  
3. TCP socket connectivity (ports 25204–25206)  
4. Traceroute  

A detailed report is written into the logs directory.

## 2. Usage (Linux)
```
chmod +x diagnose.sh  
./diagnose.sh my-domain.com
```
## 3. Output / Support

Attach the generated diagnostic log when contacting support.
