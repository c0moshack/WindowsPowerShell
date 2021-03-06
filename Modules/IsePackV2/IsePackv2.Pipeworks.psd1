@{
    # The Domain Schematics Describe How The Package Will be deployed to Azure.  
    DomainSchematics = @{
        # Each key in domain schematics is one or more domains, separated by an |
        "powershellise.com" = "Default"        
    }


    # Always allows download, even if -AllowDownload is now specified.
    AllowDownload = $true


        
    
    # The WebCommand section describes how various commands in the module will convert into web services.
    WebCommand = @{
        "Get-PowerShellIcicle" = @{
            FriendlyName = "Find Cool Icicles"
            HideParameter = "All", "Select", "ExcludeTableInfo", "MyPowerShellIcicle", 'UserId'
        }
        
        "Add-PowerShellIcicle"  = @{
            
            FriendlyName = "Share an Icicle"
            RequiresLogin = $true
        }               
    }

    LiveConnect = @{
        RedirectUrl = 'http://powershellise.com/?LiveIdConfirmed=true'
        ClientId = "00000000400FEDA5"
        ClientSecretSetting = "IsePackClientSecret"
    }
    
    # The command order indicates how each item will be displayed on the front page.
    Group = @{
        "About IsePack" = "IsePack In Action", "Fun With Show-LastOutput"
        "Icicles" = "Writing Your First Icicle", "Get-PowerShellIcicle", "Add-PowerShellIcicle"
    }

    # These settings will be propagated into the site
    SecureSettings = "AzureStorageAccountName", "AzureStorageAccountKey", "IsePackClientSecret"

    # The UserTable indicates how individuals' logon data will be stored
    UserTable = @{
        Name = "IsePackUsers"
        Partition = "Users"
        StorageAccountSetting = "AzureStorageAccountName"
        StorageKeySetting = "AzureStorageAccountKey"
    }

    # By providing an Analytics ID, Google Analytics trackers are added to each page
    AnalyticsID  = "UA-24591838-33"
    
    # By providing a Google Site Verification, Google Webmaster Tools Recognizes the Site
    GoogleSiteVerification = "mGN_qDeFWMscbG868RTnaxX_tc-fN3PQZy9zU-CSHTM"

    # By providing a Bing Validation Key, the site is verified with Bing Webmaster Tools
    BingValidationKey = "7B94933EC8C374B455E8263FCD4FE5EF"
    
    # Indicates that every page should use JQueryUI, and a custom theme

    

    Style = @{
        body = @{
            "font-family" = "'Segoe UI', 'Segoe UI Symbol', Helvetica, Arial, sans-serif"            
            'color' = '#0248B2'
            'background' = '#FFFFFF'
        }
        'a' = @{
            'color' = '#012456'
        }
        
        'a:hover' = @{
            'text-decoration' ='none'
        }
        '.MajorMenuItem' = @{
            'font-size' = 'large'
        }
        '.MinorMenuItem' = @{
            'font-size' = 'medium'            
        }
        '.ExplanationParagraph' = @{
            'font-size' = 'medium'
            'text-indent' = '-10px'
        }
        '.ModuleWalkthruExplanation' = @{
            'font-size' = 'medium'       
            'margin-right' = '3%'       
        }

        '.ModuleWalkthruOutput' = @{
            'font-size' = 'medium'           
        }
        '.PowerShellColorizedScript' = @{
            'font-size' = 'medium'
        }
        
    }

    Keyword = 'PowerShell', 'Integrated Scripting Environment'
    Logo = '/IsePackV2_Tile.png'


    Technet = @{
        Category="Scripting Techniques"
        Subcategory="Displaying Output"
        OperatingSystem="Windows 7", "Windows Server 2008", "Windows Server 2008 R2", "Windows Vista", "Windows XP", "Windows Server 2012", "Windows 8"
        Tag='PowerShell ISE', 'Pipeworks', 'Icicle', 'ISE', 'Script Editor', 'ScriptCop', 'ShowUI', 'EZout', 'PowerShell Tools', 'Start-Automating'        
        MSLPL=$true
        Summary="
IsePackV2 is a collection of tools that make the Windows Powershell ISE way cooler.  IsePack adds dozens of shortcuts and useful WPF add-ons called Icicles, and gives you tons of tools to customize the ISE.  It also includes the five most useful modules made by Start-Automating. 
"
        Url = 'http://gallery.technet.microsoft.com/IsePackV2-a5906ca9'
    }
} 
