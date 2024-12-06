[System.Collections.Generic.List[PSObject]] $JsonBuilder = @()

$JsonBuilder.Add(@{
    KeyPath = 'HKLM:\System\CurrentControlSet\Services\LanmanServer\Parameters'
    Name    = 'EnableSecuritySignature'
    Tests   = @(
        @{operator = 'ge'; value = '1'}
    )
})

$JsonBuilder.Add(@{
    KeyPath = 'HKLM:\System\CurrentControlSet\Services\LanmanServer\Parameters'
    Name    = 'MaxSize'
    Tests   = @(
        @{operator = 'ge'; value = '32768'}
    )
})

$JsonBuilder.Add(@{
    KeyPath = 'HKLM:\System\CurrentControlSet\Services\LanmanServer\Parameters'
    Name    = 'AutoDisconnect'
    Tests   = @(
        @{operator = 'in'; value = '1..15'}
    )
})

$JsonBuilder.Add(@{
    KeyPath = 'HKLM:\System\CurrentControlSet\Services\LanmanServer\Parameters'
    Name    = 'EnableForcedLogoff'
    Tests   = @(
        @{operator = 'eq'; value = '1'}
        @{operator = 'eq'; value = '$null'}            
    )
})

$JsonBuilder | convertto-json -Depth 3 | Out-File .\registrychecks.json -Encoding UTF8