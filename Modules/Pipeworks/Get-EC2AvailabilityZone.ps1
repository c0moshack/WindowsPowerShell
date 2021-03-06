function Get-EC2AvailabilityZone
{
    <#
    .Synopsis
        Gets availability zones for EC2 datacenters
    .Description
        Gets the availability zones for EC2 datacenters
    .Example
        Get-EC2AvailabilityZone
    .Link
        Get-EC2
    .Link
        Add-EC2
    #>
    param()
    
    process {
        $AwsConnections.EC2.DescribeAvailabilityZones((New-Object Amazon.EC2.Model.DescribeAvailabilityZonesRequest)).DescribeAvailabilityZonesResult.AvailabilityZone
    }
} 
