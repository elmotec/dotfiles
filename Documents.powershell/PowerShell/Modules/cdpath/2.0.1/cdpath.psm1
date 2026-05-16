using namespace System.Management.Automation
using namespace System.Management.Automation.Language


Set-StrictMode -Off
[string]  $script:PathFile = '~/.cdpath'
[string[]]$script:cdpath = $null
$script:Options = [pscustomobject] @{  
  SetWindowTitle = $true
}

$script:PreviousWorkingDir = '~'
if(-not (Test-Path $script:PathFile))
{
    Set-Content -Path $script:PathFile -Value ''
}

class CDPathCompleter : System.Management.Automation.IArgumentCompleter 
{
    [System.Collections.Generic.IEnumerable[System.Management.Automation.CompletionResult]] 
    CompleteRemaining(
                      [string] $wordToComplete,
                      [System.Management.Automation.Language.CommandAst] $commandAst,
                      [System.Collections.IDictionary] $fakeBoundParameters)
    {
         
         $cdpath = ,'.' + $script:cdpath        

         $ce = $commandAst.CommandElements[1]
         if ($ce -isnot [StringConstantExpressionAst])
         {
            return $null
         }
         $el = $commandAst.CommandElements
         $count = ($el.Count - 1)
         if ($wordToComplete){
            $count--
         }
         if($count -eq 1){
            $v = $el[1].Value
            if($v.EndsWith('\'))
            {
                $pattern = "$v\$wordtoComplete*"
            }
            else
            {
                $pattern = $v + "*\$wordtoComplete*"
            }
         }
         else{
            $v = $el[1..$count].Value
            $pattern = $v -join '*\' 
            $pattern += "*\$wordtoComplete*"
         }
         $res = [System.Collections.Generic.List[CompletionResult]]::new(10)
            
         if([io.path]::IsPathRooted($pattern))
         {
            foreach($r in Resolve-Path $pattern)
            {
                $name = $r.Substring(0,$v.length)
                $res.Add([CompletionResult]::new($name,$name, [CompletionResultType]::ProviderContainer,  $name))
            }
         }
         else{                 
             Join-Path -Path $cdpath -ChildPath $pattern -Resolve -ea:SilentlyContinue | foreach {        
                if ([io.Directory]::Exists($_))
                {
                    $name = [io.path]::GetFileName($_)
                    if ($name.Contains(' ')){
                        $name = "'$name'"
                    }
                    $res.Add([CompletionResult]::new($name,$name, [CompletionResultType]::ProviderContainer,  $name))            
                }            
             }
         }
         
         return $res
     }
     
     [System.Collections.Generic.IEnumerable[CompletionResult]] 
     CompletePath([string] $wordToComplete,
                  [CommandAst] $commandAst,
                  [System.Collections.IDictionary] $fakeBoundParameters) 
    {
        if ($commandAst.CommandElements.Count -ne 2)
        {
            return $null
        }
        $cdpath = ,'.' + $script:cdpath 
                                  

        $ce = $commandAst.CommandElements[1]
        if ($ce -isnot [StringConstantExpressionAst])
        {
            return $null
        }
        $pattern = $commandAst.CommandElements[1].Value         	
     
        $res = [System.Collections.Generic.List[CompletionResult]]::new(10)
         foreach($r in [CompletionCompleters]::CompleteFilename("$wordToComplete*"))
         {
            if($_.ResultType -eq [CompletionResultType]::ProviderContainer)
            {
                $res.Add($r)
            }
         }
     
        foreach($r in Join-Path -Path $cdpath -ChildPath "$pattern*" -Resolve -ea:SilentlyContinue)
        {        
            if ([io.Directory]::Exists($r))
            {
                if ($r.Contains(' ')){
                    $r = "'$r'"
                }
                $res.Add([CompletionResult]::new($r,$r, [CompletionResultType]::ProviderContainer,  $r))
            }
        }
        return $res
    }


     [System.Collections.Generic.IEnumerable[System.Management.Automation.CompletionResult]] 
     CompleteArgument([string] $commandName,
                      [string] $parameterName,
                      [string] $wordToComplete,
                      [System.Management.Automation.Language.CommandAst] $commandAst,
                      [System.Collections.IDictionary] $fakeBoundParameters) 
    {
        switch($parameterName)
        {
            'Path' {return $this.CompletePath($wordToComplete, $commandAst, $fakeBoundParameters);break}
            'Remaining' {return $this.CompleteRemaining($wordToComplete, $commandAst, $fakeBoundParameters)}
        }    
        return $null
    }
}
    

<#
.SYNOPSIS
  Changing location using by resolving a pattern agains a set of paths
.DESCRIPTION
  CDPath replaces the 'cd' alias with Set-CDPathLocation
  
  Parts of paths can be specified with a space.
  
  PS> cd win mo

  will change directory to ~/documents/windowspowershell/modules
  

.EXAMPLE
Set-CDPathLocation ....

The example changes the current location to the parent three levels up.
.. (first parent)
... (second parent)
.... (third parent)

.EXAMPLE
Set-CDLocation 'C:\Program Files (X86)\Microsoft Visual Studio 12'
Set-CDLocation ~
# Go back to 'C:\Program Files (X86)\Microsoft Visual Studio 12'
Set-CDPathLocation -

.EXAMPLE

Get-CDPath
~/Documents/GitHub
~/Documents
~/corpsrc

# go to ~/documents/WindowsPowerShell/Modules/CDPath
Set-CDLocation win mod cdp


#>
function Set-CDPathLocation 
{
  param(
    [Parameter(Position=0)]
    [ArgumentCompleter([CDPathCompleter])]
    [string] $Path,
    [Parameter(ValueFromRemainingArguments)]
    [ArgumentCompleter([CDPathCompleter])]
    [string[]] $Remaining=$null,
    [switch] $Exact
    )

  $CurrentWorkingDir = $Pwd.ProviderPath      
  $NewPath = $null
  
  # If there are extra arguments, create a globbing expression
  # so that cd a b c => cd a*\b*\c*
  if ($Remaining)
  {        
    $ofs='*\'
    $path= "$path*\$Remaining*"	
  }	
  
  # Resolve Path
  if (!$Path) 
  {
    $Path = '~'
  }
  
  # .'ing shortcuts for ... and ....
  if ($Path -match "^\.{3,}$")
  {
    $Path = $path.Substring(1) -replace '\.','..\'
  } 
  
  
  if ($Path -eq '-')
  {
    # pop back to your old Path
    Set-Location $script:PreviousWorkingDir
    $script:PreviousWorkingDir = $CurrentWorkingDir
    return
  }
  # See if the location exists. If it does not, use $CDPath to
  # resolve to a location that exists    
  if (Test-Path $Path -ea SilentlyContinue)
  {
    $NewPath = $Path
  }
  else
  {
    if ($Exact)
    {
      $paths = Join-Path $cdpath "$path"
    }
    else 
    {                  
      $paths = Join-Path $cdpath "$path*" -Resolve -ea SilentlyContinue
    }
    if ($paths) {
      if ($paths -is [string])
      {
        $NewPath=$paths
      } 
      else 
      {
        # find the first match that is a container
        $res=Test-Path -PathType:Container $paths
        for($i=0; $i -lt $res.Length;++$i)
        {
          if ($res[$i])
          {
            $NewPath=$paths[$i]
            break
          } #if
        } #for        
      } 
    } #if $paths
    # clear $newpath if it is not a directory
    if($NewPath -and !(Test-Path $NewPath -PathType:Container))
    {
      $NewPath=$null
    }
    
  }#else
  
  if ($NewPath )
  {
    $script:PreviousWorkingDir = $Pwd.ProviderPath
    $newPath = (Resolve-Path -path $NewPath).ProviderPath
    Set-Location -Path $NewPath
    if($script:Options.SetWindowTitle)
    {

      $Host.UI.RawUI.WindowTitle=$NewPath
    }
  } 
  else 
  {
    if (Test-Path $path -ea SilentlyContinue) 
    {
      Set-Location $path
    }
    else {
      Write-Error "Directory not found: $path"
    }
  }    
}

<#
.SYNOPSIS
    Read the cdpath from ~/.cdpath

.DESCRIPTION
    This is useful if you have modified your path file with an external editor
#>
function Update-Cdpath 
{
  $script:cdpath=Get-Content -Path $script:PathFile | 
    Where-Object {$_.Trim()} |   
    ForEach-Object { $ExecutionContext.InvokeCommand.ExpandString($_) }         
}

<#
.SYNOPSIS
    Adds one or more paths to your cdpath

.DESCRIPTION
    This is useful if you have modified your path file with an external editor
#>
function Add-CDPath 
{
  param(
    [string[]] $Path
    ,
    # Specify Prepend to add the paths before the existing paths
    [Switch] $Prepend
  )
  
  if ($Prepend)
  {
    Set-CDPath @($Path + $script:cdpath)
  }
  else
  {
    Set-CDPath @($script:cdpath + $Path)
  }  
}


function Get-CDPath
{
  $script:cdpath
}

function Get-CDPathOption
{
  $script:Options
}

function Set-CDPath
{
  param(
    [Parameter(Mandatory)]
    [string[]] $Path
  )
  $script:CDPath = $Path  
  $ofs = [Environment]::NewLine
  Set-Content -Path $script:PathFile  -value $Path
}

<#
.SYNOPSIS
  Customizes the behavior of Set-CDPathLocation in CDPath
#>
function Set-CDPathOption
{
  param(    
    # Indicates if the the window title should be changed when changing location
    [Switch] $SetWindowTitle   
  ) 
  if($PSBoundParameters.ContainsKey('SetWindowTitle'))
  {
    $script:Options.SetWindowTitle = [bool] $SetWindowTitle
  }     
}

# read cdpath from file
Update-Cdpath

if ($script:cdpath -EQ $null)
{
  Set-CDPath ~,~/documents,$env:programfiles  
}


Set-Alias -Name cd -Value Set-CDPathLocation -Description 'Use fast navigation between the path defined by cdpath.txt'


# SIG # Begin signature block
# MIINLAYJKoZIhvcNAQcCoIINHTCCDRkCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUBIkLF5UzCvjn6OuBJu2+AHO5
# 6q6gggpuMIIFMDCCBBigAwIBAgIQBAkYG1/Vu2Z1U0O1b5VQCDANBgkqhkiG9w0B
# AQsFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVk
# IElEIFJvb3QgQ0EwHhcNMTMxMDIyMTIwMDAwWhcNMjgxMDIyMTIwMDAwWjByMQsw
# CQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cu
# ZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQg
# Q29kZSBTaWduaW5nIENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
# +NOzHH8OEa9ndwfTCzFJGc/Q+0WZsTrbRPV/5aid2zLXcep2nQUut4/6kkPApfmJ
# 1DcZ17aq8JyGpdglrA55KDp+6dFn08b7KSfH03sjlOSRI5aQd4L5oYQjZhJUM1B0
# sSgmuyRpwsJS8hRniolF1C2ho+mILCCVrhxKhwjfDPXiTWAYvqrEsq5wMWYzcT6s
# cKKrzn/pfMuSoeU7MRzP6vIK5Fe7SrXpdOYr/mzLfnQ5Ng2Q7+S1TqSp6moKq4Tz
# rGdOtcT3jNEgJSPrCGQ+UpbB8g8S9MWOD8Gi6CxR93O8vYWxYoNzQYIH5DiLanMg
# 0A9kczyen6Yzqf0Z3yWT0QIDAQABo4IBzTCCAckwEgYDVR0TAQH/BAgwBgEB/wIB
# ADAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYBBQUHAwMweQYIKwYBBQUH
# AQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQwYI
# KwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFz
# c3VyZWRJRFJvb3RDQS5jcnQwgYEGA1UdHwR6MHgwOqA4oDaGNGh0dHA6Ly9jcmw0
# LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwOqA4oDaG
# NGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RD
# QS5jcmwwTwYDVR0gBEgwRjA4BgpghkgBhv1sAAIEMCowKAYIKwYBBQUHAgEWHGh0
# dHBzOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwCgYIYIZIAYb9bAMwHQYDVR0OBBYE
# FFrEuXsqCqOl6nEDwGD5LfZldQ5YMB8GA1UdIwQYMBaAFEXroq/0ksuCMS1Ri6en
# IZ3zbcgPMA0GCSqGSIb3DQEBCwUAA4IBAQA+7A1aJLPzItEVyCx8JSl2qB1dHC06
# GsTvMGHXfgtg/cM9D8Svi/3vKt8gVTew4fbRknUPUbRupY5a4l4kgU4QpO4/cY5j
# DhNLrddfRHnzNhQGivecRk5c/5CxGwcOkRX7uq+1UcKNJK4kxscnKqEpKBo6cSgC
# PC6Ro8AlEeKcFEehemhor5unXCBc2XGxDI+7qPjFEmifz0DLQESlE/DmZAwlCEIy
# sjaKJAL+L3J+HNdJRZboWR3p+nRka7LrZkPas7CM1ekN3fYBIM6ZMWM9CBoYs4Gb
# T8aTEAb8B4H6i9r5gkn3Ym6hU/oSlBiFLpKR6mhsRDKyZqHnGKSaZFHvMIIFNjCC
# BB6gAwIBAgIQC00BIFzepyXTcMbB+AfaoDANBgkqhkiG9w0BAQsFADByMQswCQYD
# VQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGln
# aWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQgQ29k
# ZSBTaWduaW5nIENBMB4XDTE1MDgxMTAwMDAwMFoXDTE4MDgxNTEyMDAwMFowfTEL
# MAkGA1UEBhMCU0UxFzAVBgNVBAgTDlN0b2NraG9sbXMgTGFuMREwDwYDVQQHDAhT
# a8O2bmRhbDEgMB4GA1UEChMXUG93ZXJDb2RlIENvbnN1bHRpbmcgQUIxIDAeBgNV
# BAMTF1Bvd2VyQ29kZSBDb25zdWx0aW5nIEFCMIIBIjANBgkqhkiG9w0BAQEFAAOC
# AQ8AMIIBCgKCAQEA0Yu390VGptjUZIdLxIYQCSG1atPh/tN6qPf/eovS3ohJy+td
# XluaPkUXuE3fWeMp+p3Jsj3c/LdsA1iYiQQQnJ/9afqiW2hnmSkNZfgcLQ9mceXl
# mmd2otcwfkVhfA6ZuFnpceFgKciLLld7AY1sMiSyc1L5RvEsOR/1S6uBg0AWoSSv
# l44vF8EgeArhPCx8GNbUmYfEpeqs1f5LOLlQBwImGCsjv1rmbuPwt0E229XVLerU
# auNXJjb+jtrGBTzD384QiLMGtNHWnE4yBStjrLTHHNz4mE0g6jUIYJbFvGLD04Cl
# 7WovOkODL+9nmsyreUg2UVBKrO98GK/G8XhG8wIDAQABo4IBuzCCAbcwHwYDVR0j
# BBgwFoAUWsS5eyoKo6XqcQPAYPkt9mV1DlgwHQYDVR0OBBYEFAGtca5rM/ejkFdY
# 3OVLhIxGkpIBMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcDAzB3
# BgNVHR8EcDBuMDWgM6Axhi9odHRwOi8vY3JsMy5kaWdpY2VydC5jb20vc2hhMi1h
# c3N1cmVkLWNzLWcxLmNybDA1oDOgMYYvaHR0cDovL2NybDQuZGlnaWNlcnQuY29t
# L3NoYTItYXNzdXJlZC1jcy1nMS5jcmwwQgYDVR0gBDswOTA3BglghkgBhv1sAwEw
# KjAoBggrBgEFBQcCARYcaHR0cHM6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzCBhAYI
# KwYBBQUHAQEEeDB2MCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5j
# b20wTgYIKwYBBQUHMAKGQmh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdp
# Q2VydFNIQTJBc3N1cmVkSURDb2RlU2lnbmluZ0NBLmNydDAMBgNVHRMBAf8EAjAA
# MA0GCSqGSIb3DQEBCwUAA4IBAQC+nkBDDZo+AvHQdEm2IA9ygsJIQccvEE/ijFoq
# RHqje75atqGhfzcVyqjyRdhj7FJ2WGvcWsHahViDq9ZR5W42S6D9OG0c+Wmo6buc
# jn1Y8lfaWIngCloNZ0BF7rBcVmR8JLkfKjVZSsHdbBKVxj3x7NYw9cr7nx/UQjXX
# jghqtWMetHOlw73BKpDEJGs7LFtb8TZcNLVyWU4GuW1HWhncf5lq2b3WUP82xKIa
# Pf7w50P33/xxo+N12nNJJQ82aIhUVhVXcZ+TWlfO2n0yZT7dsa1FFwRf/dGPIpZm
# Kn8tanILjQg5K4NWlli2iLonrmRmqXAlXe8NSPTXWPvaNskAMYICKDCCAiQCAQEw
# gYYwcjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UE
# CxMQd3d3LmRpZ2ljZXJ0LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1
# cmVkIElEIENvZGUgU2lnbmluZyBDQQIQC00BIFzepyXTcMbB+AfaoDAJBgUrDgMC
# GgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYK
# KwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG
# 9w0BCQQxFgQU+zMYhbX9RtZqvVbTZrar73M3AcQwDQYJKoZIhvcNAQEBBQAEggEA
# YOfq26CF2zPRTR+VOTcZTRbYI7XMV2J4Ys/FlD2Ehvt1G7WDathpKItoEuI36Zco
# ZhZbxC0nUEAjWdXCU2yzweHKP/+EIRq6Iwt8HqupvDCYu3IUltsYoqhMKEVtBaZG
# 8cFxZYo0Rxbf2Fzn39CIbozhQxxZ0YOpOOHJxOaWJxYoFe/Tzfaq+MNfwUkzTH5L
# mFzh25qMxwyKPm4dLuP5eEYG04AyLTFvLSPms3F/XNCgtsfT85IQsJekGWDMIsQy
# ijWfJ7F7qP85c4xaiCisqNtrlsXGK7Tbv++I+20JCn9c5bB50MZeZeDDlc30tnNs
# zTqQ4hJWC+nlkgyUzNabSw==
# SIG # End signature block
