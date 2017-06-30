Class RunspaceHelper
{
    $RunspacePool;
    [System.Collections.ArrayList]$Jobs;
    [int]$Throttle = 5;
    [int]$Min = 1;
    $thisHost = $Host;

    RunspaceHelper()
    {
        $this.RunspacePool= [runspacefactory]::CreateRunspacePool($this.Min,$this.Throttle,[system.management.automation.runspaces.initialsessionstate]::CreateDefault(),$this.thisHost);
        $this.Jobs = (New-Object System.Collections.ArrayList);
    }

    RunspaceHelper([int]$throttle)
    {
        $this.RunspacePool= [runspacefactory]::CreateRunspacePool($this.Min,$throttle,[system.management.automation.runspaces.initialsessionstate]::CreateDefault(),$this.thisHost);
        $this.Jobs = (New-Object System.Collections.ArrayList);
    }

    [void]Open()
    {
        $this.RunspacePool.Open();
    }

    [PSobject]GetReturnData()
    {
        $return = $this.Jobs | ForEach {
            $_.powershell.EndInvoke($_.handle)
            $_.PowerShell.Dispose()
        }
        return $return
    }

    [void]ExecuteScript([ScriptBlock]$scriptBlock,[hashtable]$params)
    {
        $PowerShell = [powershell]::Create() 
        $PowerShell.RunspacePool = $this.RunspacePool
        
        [void]$PowerShell.AddScript($scriptBlock)
        [void]$PowerShell.AddParameters($params)
        $Handle = $PowerShell.BeginInvoke()
        $temp = ”" | Select PowerShell,Handle
        $temp.PowerShell = $PowerShell
        $temp.handle = $Handle 
        [void]$this.Jobs.Add($Temp)
        
        Write-Debug (“Available Runspaces in RunspacePool: {0}” -f $this.RunspacePool.GetAvailableRunspaces())

        Write-Debug (“Remaining Jobs: {0}” -f @($this.Jobs | Where {$_.handle.iscompleted -ne ‘Completed’ }).Count)
    }

    [void]Close()
    {
        $this.Jobs.clear()
        $this.RunspacePool.Close()
    }

    [PSObject]GetAvailableRunspaces()
    {
        return $this.RunspacePool.GetAvailableRunspaces()
    }
}
