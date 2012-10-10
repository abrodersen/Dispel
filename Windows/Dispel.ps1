$request_interval = 10000
$cache_level = [System.Net.Cache.RequestCacheLevel]::NoCacheNoStore
[System.Net.HttpWebRequest]::DefaultCachePolicy = $cache_level

$redirect_detected = $FALSE
$network_status = [System.Net.NetworkInformation.NetworkInterface]::GetIsNetworkAvailable()


Function Get-Resource
{
    Param(
        [string]$test_uri = "http://www.google.com/",
        [int]$timeout = 5000,
        [string]$user_agent = "Mozilla/5.0 (X11; Linux i686; rv:2.0) Gecko/20100101 Firefox/4.0")
        
        $stopwatch = New-Object System.Diagnostics.Stopwatch
        
        $request = [System.Net.HttpWebRequest] [System.Net.WebRequest]::Create($test_uri)
        $request.Method = "GET"
        $request.UserAgent = $user_agent
        $request.AllowAutoRedirect = $FALSE
        $request.KeepAlive = $FALSE
        $request.Timeout = $timeout
        
        Write-Host -NoNewline ("GET " + $test_uri + "    ").PadRight(35)
        
        $stopwatch.Start()
        $response =  [System.Net.HttpWebResponse] $request.GetResponse()
        $stopwatch.Stop()
        
        $output = ([int]$response.StatusCode).ToString() + " " + $response.StatusDescription + " (" + $stopwatch.ElapsedMilliseconds + " ms)"
        Write-Host $output
        
        return $response
}
$exiting = $FALSE


do {
    $old_status = $network_status
    $network_status = [System.Net.NetworkInformation.NetworkInterface]::GetIsNetworkAvailable()
    if($network_status -and !$old_status)
    {
        Write-Host "Network connection established."
        $request_interval = 10000
        Start-Sleep -m 3000
    }
    if(!$network_status -and $old_status)
    {
        Write-Host "Network connection lost. Waiting for reconnect..."
        $request_interval = 1000
    }
    
    if($network_status)
    {
        Try
        {    
            $response = Get-Resource
           
            $status_code = [System.Int32] $response.StatusCode
            
            $redirect_detected = $status_code -ne 200
            
        }
        Catch [System.Net.WebException]
        {
            Write-Host "An network error occured performing the request."
            
        }
        Catch [System.Exception]
        {
            Write-Host "An unkown error occured while performing the request."
            $_.Exception.ToString()
        }
        Finally
        {
            if($response)
            {
                $response.Close()
            }
        }
    }
    
	if(!$redirect_detected)
    {
	   Start-Sleep -m $request_interval
    }
    else
    {
        while($response.StatusCode -ne [System.Net.HttpStatusCode]::OK)
        {
            try
            {
                $response = Get-Resource $response.Headers.Get("Location").ToString()
            }
            catch [System.Exception]
            {
                break;
            }
            finally
            {
                if($response)
                {
                    $response.Close()
                }
            }
        }
    }
}
while( $exiting -eq $FALSE)