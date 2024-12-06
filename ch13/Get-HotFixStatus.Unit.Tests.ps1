BeforeAll {
    Set-Location -Path $PSScriptRoot
    . .\Get-HotFixStatus.ps1
    $Id = 'KB1234567'
}

Describe 'Get-HotFixStatus' {
    Context "Hotfix Found" {
        BeforeAll { Mock Get-HotFix {} }
        It "Hotfix id found on the Computer" {
            $KBFound = Get-HotFixStatus -Id $Id -Computer 'localhost'
            $KBFound | Should -Be $true
        }
    }
    Context "Hotfix not found" {
        BeforeAll {
            Mock Get-Hotfix { 
                throw ('GetHotFixNoEntriesFound,' + 'Microsoft.PowerShell.Commands.GetHotFixCommand')
            }
        }
        It "Hotfix is not found on the Computer" {
            $KBFound = Get-HotFixStatus -Id $Id -Computer 'localhost'
            $KBFound | Should -Be $false
        }    
    }

    Context "Not able to connect to remote machine" {
        BeforeAll {
            Mock Get-HotFix {
                throw ('System.Runtime.InteropServices.COMException,' + 'Microsoft.PowerShell.Commands.GetHotFixCommand')
            }
        }    
        It "Unable to connect" {
            { Get-HotFixStatus -Id $Id -Computer 'dummy' } | Should -Throw
        }
    
    }
}