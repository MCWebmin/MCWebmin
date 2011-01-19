<?php

class Connection
{
	private $socket;
	private $errstr;
	private $errno;
	private $status;
	
	public function Connection($host, $port, $password)
	{
		$this->socket = pfsockopen($host,$port,$this->errno,$this->errstr,10);
		if ($this->socket === false)
		{
			fclose($this->socket);
			$this->status = "HOST_DOWN";
		} else
		{
			// server wants password now?
			$response = fgets($this->socket,1024);
			if (strpos($response,"enter the password"))
			{
				$this->auth($password);
			} else {
				fclose($this->socket);
				$this->status = "BAD_SERV_RESP";
			}
		}
	}
	
	public function auth($password)
	{
		if (fwrite($this->socket,$password))
		{
			$response = fgets($this->socket,1024);
			if (substr($response,0,1) == "-")
			{
				$this->status = "BAD_PASSWORD";
			} else
			{
				$this->status = "READY";
			}
		} else 
		{
			fclose($this->socket);
			$this->status = "CONNECTION_WRITE_ERROR";
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
