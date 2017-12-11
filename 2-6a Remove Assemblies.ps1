$bDebug = 0
$LoadFolder = '\\NVSFTCTRLP01\C$\ASMTouchChecks\PROD\Environment\'
$LoadServerFile = $LoadFolder + 'WebServers.txt'
$Computers       = Get-Content $LoadServerFile

ForEach ($computer in $computers)
{
    $NewPSSession = New-PSSession -ComputerName $computer
    Invoke-Command -Session $NewPSSession -ScriptBlock {
        <#
        .SYNOPSIS
            Gets the assemblies in the GAC
        .DESCRIPTION
            Gets the assemblies in the GAC. Assemblies can be filterd by Name, Version, Culture, PublicKeyToken or ProcessArchitecture.
        .PARAMETER Name
            Filter on the Name part. Supports wildcards.
        .PARAMETER Version
            Filter on the Version part. Supports wildcards.
        .PARAMETER Culture
            Filter on the Culture part. 'neutral' or '' can be used to filter on assemblies without cultures. Supports wildcards.
        .PARAMETER PublicKeyToken
            Filter on the PublicKeyToken part. Supports wildcards.	
        .PARAMETER ProcessorArchitecture
            Filter on the ProcessorArchitecture part. Supports wildcards.	
        .PARAMETER AssemblyName
            Filter on AssemblyName. Must be fully qualified. See Test-AssemblyNameFullyQualified.
        .INPUTS
	        [System.Reflection.AssemblyName[]]
        .EXAMPLE
            C:\PS> Get-GacAssembly

            This example returns all assemblies in the GAC.
        .EXAMPLE
            C:\PS> Get-GacAssembly -Name System* -Version 2.0.0.0

            This example returns all assemblies in the GAC with a name starting with System and version 2.0.0.0.
        .LINK
	        Test-AssemblyNameFullyQualified
        .LINK
	        http://powershellgac.codeplex.com
        #>
        function Get-GacAssembly
        {
	        [CmdletBinding(DefaultParameterSetName = 'PartsSet')]
            [OutputType('System.Reflection.AssemblyName')]
	        param
            (
                [Parameter(Position = 0, ParameterSetName = 'PartsSet')]
                [ValidateNotNullOrEmpty()] 
                [string[]] $Name,

                [Parameter(Position = 1, ParameterSetName = 'PartsSet')]
                [ValidateNotNullOrEmpty()]
                [string[]] $Version,

                [Parameter(Position = 2, ParameterSetName = 'PartsSet')]
                [ValidateNotNullOrEmpty()]
                [string[]] $Culture,

                [Parameter(Position = 3, ParameterSetName = 'PartsSet')]
                [ValidateNotNullOrEmpty()]
                [string[]] $PublicKeyToken,

                [Parameter(Position = 4, ParameterSetName = 'PartsSet')]
		        [ValidateNotNullOrEmpty()]
                [System.Reflection.ProcessorArchitecture[]] $ProcessorArchitecture,

                [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'AssemblyNameSet')]
		        [ValidateNotNullOrEmpty()]
                [ValidateScript( { Test-AssemblyNameFullyQualified $_ } )]
                [System.Reflection.AssemblyName[]] $AssemblyName
	        )

            process
            {
                if ($PsCmdlet.ParameterSetName -eq 'AssemblyNameSet')
                {
                    $fullNames = @()
                    foreach ($assmName in $AssemblyName)
                    {
                        $fullNames += $assmName.FullyQualifiedName
                    }

                    foreach ($assembly in [PowerShellGac.GlobalAssemblyCache]::GetAssemblies())
                    {
                        $fullyQualifiedAssemblyName = $assembly.FullyQualifiedName
                        foreach ($fullName in $fullNames)
                        {
                            if ($fullyQualifiedAssemblyName -eq $fullName)
                            {
                                $assembly
                                break
                            } 
                        }
                    }
                }
                else
                {
                    foreach ($assembly in [PowerShellGac.GlobalAssemblyCache]::GetAssemblies())
                    {
                        $hit = $false
                        foreach ($n in $Name)
                        {
                            if ($assembly.Name -like $n)
                            {
                                $hit = $true
                                break
                            }
                        }
                        if ($Name -and -not $hit)
                        {
                            continue
                        }

                        $hit = $false
                        foreach ($v in $Version)
                        {
                            if ($assembly.Version -like $v)
                            {
                                $hit = $true
                                break
                            }
                        }
                        if ($Version -and -not $hit)
                        {
                            continue
                        }

                        $hit = $false
                        foreach ($c in $Culture)
                        {
                            if ($c -eq 'neutral' -and $assembly.CultureInfo.Equals([System.Globalization.CultureInfo]::InvariantCulture))
                            {
                                $hit = $true
                                break
                            }
                            if ($c -ne 'neutral' -and $assembly.CultureInfo -like $c)
                            {
                                $hit = $true
                                break
                            }
                        }
                        if ($Culture -and -not $hit)
                        {
                            continue
                        }

                        $hit = $false
                        foreach ($p in $PublicKeyToken)
                        {
                            if ($assembly.PublicKeyToken -like $p)
                            {
                                $hit = $true
                                break
                            }
                        }
                        if ($PublicKeyToken -and -not $hit)
                        {
                            continue
                        }    

                        $hit = $false
                        foreach ($p in $ProcessorArchitecture)
                        {
                            if ($assembly.ProcessorArchitecture -eq $p)
                            {
                                $hit = $true
                                break
                            }
                        }
                        if ($ProcessorArchitecture -and -not $hit)
                        {
                            continue
                        }           

                        $assembly
                    }
                }
            }
        }

        <#
        .SYNOPSIS
            Removes the assembly from the GAC
        .DESCRIPTION
            Removes the assembly from the GAC. Can only be called from an elevated prompt.
        .PARAMETER AssemblyName
            Specifies the assembly name. Must be fully qualified. See Test-AssemblyNameFullyQualified.
        .PARAMETER InstallReference
	        Specifies the InstallReference used to remove the assembly from the GAC.
        .PARAMETER PassThru
	        The AssemblyName removed is returned as output
        .INPUTS
	        [System.Reflection.AssemblyName[]]
        .EXAMPLE
            C:\PS> Get-GacAssembly -Name SomeAssembly | Remove-GacAssembly

            This example removes all assemblies with the name SomeAssembly from the GAC.
        .LINK
	        Test-AssemblyNameFullyQualified
        .LINK
	        http://powershellgac.codeplex.com
        #>
        function Remove-GacAssembly
        {
	        [CmdletBinding(SupportsShouldProcess = $true)]
            [OutputType('System.Reflection.AssemblyName')]
	        param
            (
                [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
                [ValidateNotNullOrEmpty()]
                [ValidateScript( { Test-AssemblyNameFullyQualified $_ } )]
                [System.Reflection.AssemblyName[]] $AssemblyName,

                [Parameter(Position = 1)]
                [ValidateNotNullOrEmpty()]
                [ValidateScript( { Test-GacAssemblyInstallReferenceCanBeUsed $_ } )]
                [PowerShellGac.InstallReference] $InstallReference,

                [Switch] $PassThru
	        )

            process
            {
                foreach ($assmName in $AssemblyName)
                {
			        $fullyQualifiedAssemblyName = $assmName.FullyQualifiedName

			        if (!$PSCmdLet.ShouldProcess($fullyQualifiedAssemblyName))
			        {
				        continue
			        }

			        $disp = [PowerShellGac.GlobalAssemblyCache]::UninstallAssembly($assmName, $InstallReference) 
        
			        switch ($disp)
			        {
				        Unknown
				        {
					        Write-Error -Message 'Unknown Error' -Category InvalidResult -TargetObject $assmName
				        }
				        Uninstalled
				        {
					        Write-Verbose "Removed $fullyQualifiedAssemblyName from the GAC"
				        }
				        StillInUse
				        {
					        Write-Error -Message 'Still in use. An application is using the assembly.' -Category PermissionDenied -TargetObject $assmName
				        }
				        AlreadyUninstalled
				        {
					        Write-Error -Message 'Already uninstalled. The assembly does not exist in the GAC.' -Category NotInstalled -TargetObject $assmName
				        }
				        DeletePending
				        {
					        Write-Error -Message 'Delete pending' -Category ResourceBusy -TargetObject $assmName
				        }
				        HasInstallReference
				        {
					        Write-Error -Message 'Has install reference. The assembly has not been removed from the GAC because another install reference exists.' -Category PermissionDenied -TargetObject $assmName
				        }
				        ReferenceNotFound
				        {
					        Write-Error -Message 'Reference not found. The reference that is specified is not found in the GAC' -Category ObjectNotFound -TargetObject $assmName
				        }
				        default 
				        {
					        Write-Error -Message "Unknown Error: $disp" -Category InvalidResult -TargetObject $assmName
				        }
			        }

			        if ($PassThru)
			        {
				        $assmName
			        }
                }
            }
        }

        Get-GacAssembly -Name *StayinFront* | Remove-GacAssembly
    }

}