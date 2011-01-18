<?php

class Connection
{
	private $socket;
	private $errstr;
	private $errno;
	private $status;
	
	public function Connection($host, $port, $password)
	{
		$this->socket = fsockopen($host,$port,$this->errno,$this->errstr,10);
		if ($this->socket === false)
		{
			return "HOST_DOWN";
		} else
		{
			if (fwrite($this->socket,$password))
			{
				$response = fgets($this->socket,1024);
				echo $response;
				if (strpos($response,"enter the password"))
				{
					// server wants password, give it to it
				} else {
					$this->status = "BAD_SERV_RESP";
				}
			} else {
				fclose($this->socket);
				return "SERV_HATES_US";
			}
		}
	}
	
	public function getStatus()
	{
		return $this->status;
	}
	
	public function sendCommand($command)
	{
		
	}
	
}

?>
