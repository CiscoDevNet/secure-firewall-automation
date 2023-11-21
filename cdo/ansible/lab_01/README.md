# Cisco Defense Orchestrator Ansible Collection Sample Playbooks

# CDO API Key, CDO Region, and Device Passwords:
An API token should be considered just as sensitive as an administrator's password. As such, we would never want to code the API key or device passwords into our playbooks or inventory files. Best practice would be to store the API key, passwords, and other sensitive information in a password vault application like [Hashicorp's Vault](https://www.vaultproject.io/), or encrypt the secrets with something like [Ansible Vault](https://docs.ansible.com/ansible/latest/vault_guide/index.html) and then pass the vault decryption key at runtime. These excellent strategies are beyond the scope of this course, so we will use an arguably less secure, but often used practice, of supplying the API key and other secret data as environment variables.  
```
export CDO_API_KEY="xxxxx"
export CDO_REGION="us"
export ASA_PASSWORD='xxxxx'
export FTD_PASSWORD='xxxxx'
export IOS_PASSWORD='xxxxx'
export ASA_USERNAME="cisco"
export IOS_USERNAME="cisco"
export SDC="CDO_cisco_my_tenant-SDC-1"
```

## Sample usage:
```
ansible-playbook -i inventory.yml --extra-vars="ansible_python_interpreter=$(which python)" add_asa_ios.yml
```  
- `-i inventory.yml` is the path to your inventory file of devices to add  
- `--extra-vars="ansible_python_interpreter=$(which python)"` ensures that ansible uses the correct python3 libraries from your current shell. You may not need this command if you are running your python from a python venv  
- `add_asa_ios.yml` is the playbook to run against the inventory  

### Limit playbook to a single host  
Often you may want to run a deploy or delete operation against 1 device and not the entire inventory. Rather than create specialized inventory files or playbooks, you can limit the playbook to a specific host with the following parameter:  
`--limit=DeviceName`  
e.g. `--limit=Austin`  

## Notes  
- Use the sample Ansible inventory file `inventory.yml` for inventory definition examples of devices to add to CDO and general operations  
- Passwords and API keys should NEVER be stored in clear text in inventory or playbooks. Use Ansible vault, environment variables, or other best practices to sote passwords and API keys  
- `device_inventory_playbooks/add_asa_ios.yml` and `device_inventory_playbooks/add_ftd.yml` are playbook examples of how to use the sample inventory file `inventory.yml` to add devices to CDO  
  - Adds:  
    - ASA devices
    - FTD devices, both via CLI ("configure manager" command) and using Low Touch Provisioning (LTP)  
    - IOS Devices like Cisco routers and catalyst switches  
  - If a device IP/Port/Name already exists in CDO, the device will be skipped and a DuplicateObject error raised and logged to output  
- `device_inventory_playbooks/delete_devices.yml` is a playbook example on how to delete devices from CDO using the sample inventory. CAUTION: THIS WILL DELETE ALL OF THE DEVICES IN YOUR INVENTORY FILE FROM CDO. You can pick which device to delete using the --limit=DeviceName parameter when running the playbook.  
