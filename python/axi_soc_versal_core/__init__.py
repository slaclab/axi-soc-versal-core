from axi_soc_versal_core._AxiVersion     import *
from axi_soc_versal_core._AxiSocCore     import *

import click
import subprocess

def connectionTest(ip):
    try:
        subprocess.check_output(["ping", "-c", "1", ip])
        portStatus = subprocess.getoutput(f'netstat -t | grep {ip}:9000 | grep ESTABLISHED')
        if portStatus != '':
            errMsg = f"""
                {portStatus}
                Failied to open {ip} at port=9000
                Likely another thread has the software running
                """
            click.secho(errMsg, bg='red')
            raise ValueError(errMsg)
    except subprocess.CalledProcessError:
        errMsg = f"""
            Failied to ping {ip}
            Double check that the board is powered up
            Double check that the board has Ethernet cable connected to NIC or Ethernet switch
            Double check isc-dhcp-server.service is running
            Double check the IP address
            """
        click.secho(errMsg, bg='red')
        raise ValueError(errMsg)
