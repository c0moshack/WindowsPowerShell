function Out-RssFeed
{
    <#
    .Synopsis
        Outputs RSS items into an RSS feed
    .Description
        Outputs RSS items into an RSS feed.  Items can be easily created with New-RssItem    
    .Example
        New-RssItem -Title "My Vacation" -Category Stupid, Stuff -Link http://bit.ly/myvacation -Author Bob -Description "Stuff I did on my vacation" | 
            Out-RssFeed -Title "My Blog" -Description "Things I Decided To Say to the World" -Link "http://my.blog"
    .Link
        New-RssItem    
    #>
    [OutputType([String])]
    param(
    # An Rss Item
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [ValidateScript({
        $asXml = $_ -as [xml]        
        if ((-not $asxml.Item)) {
            throw "The root of a format XML most be an item element"
        }
        return $true
    })]
    [string[]]
    $Item,
    
    # The title of the RSS feed
    [Parameter(Mandatory=$true)]
    [string]$Title,
    # The description of the RSS feed
    [Parameter(Mandatory=$true)]
    [string]$Description,
    # The date the feed was published
    [DateTime]$DatePublished =  [DateTime]::UtcNow,
    # A Link to the feed page
    [Parameter(Mandatory=$true)]
    [Uri]$Link
    )
    
    begin {
        $rssItems = New-Object Collections.ArrayList 
    }
    
    process {
        $null = $rssItems.Add(($Item -join "
"))
    }
    
    end {
        $rssXml = [xml]@"
<rss version="2.0">
    <channel>
        <title>$([Security.SecurityElement]::Escape($title))</title>
        <creator>$([Security.SecurityElement]::Escape($Author))</creator>
        <pubDate>$($DatePublished.ToString('r'))</pubDate>
        <description>$([Security.SecurityElement]::Escape($description))</description>
        <link>$([Security.SecurityElement]::Escape($link))</link>    
        $($rssItems -join '')
    </channel>
</rss>  
"@        
        if (-not $rssXml) { return } 
        $strWrite = New-Object IO.StringWriter
        $rssXml.Save($strWrite)
        $prettyXml = "$strWrite"
        $prettyXml.Substring($prettyXml.IndexOf(">") + 3)                
    }
}