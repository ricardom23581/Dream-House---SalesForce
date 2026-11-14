$base = "force-app\main\default"
$obj  = "$base\objects\House__c"
New-Item -ItemType Directory -Force "$obj\fields","$base\tabs","$base\permissionsets" | Out-Null
function W($path, $txt) { [IO.File]::WriteAllText((Join-Path $PWD $path), $txt) }
$h = '<?xml version="1.0" encoding="UTF-8"?>'

W "$obj\House__c.object-meta.xml" @"
$h
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
    <deploymentStatus>Deployed</deploymentStatus>
    <enableReports>true</enableReports>
    <enableSearch>true</enableSearch>
    <label>House</label>
    <nameField><label>House Name</label><type>Text</type></nameField>
    <pluralLabel>Houses</pluralLabel>
    <sharingModel>ReadWrite</sharingModel>
</CustomObject>
"@

function TextField($api, $label, $len) {
W "$obj\fields\$api.field-meta.xml" @"
$h
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>$api</fullName><label>$label</label><length>$len</length>
    <required>false</required><type>Text</type>
</CustomField>
"@ }
function NumField($api, $label, $p, $s, $type) {
W "$obj\fields\$api.field-meta.xml" @"
$h
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>$api</fullName><label>$label</label><precision>$p</precision><scale>$s</scale>
    <required>false</required><type>$type</type>
</CustomField>
"@ }

TextField "Address__c" "Address" 255
TextField "State__c" "State" 50
TextField "City__c" "City" 100
TextField "Zip__c" "Zip" 10
NumField "Bedroom__c" "Bedroom" 2 0 "Number"
NumField "Bathrooms__c" "Bathrooms" 2 0 "Number"
NumField "Price__c" "Price" 12 2 "Currency"

W "$obj\fields\Picture__c.field-meta.xml" @"
$h
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Picture__c</fullName><label>Picture</label>
    <required>false</required><type>Url</type>
</CustomField>
"@

W "$base\tabs\House__c.tab-meta.xml" @"
$h
<CustomTab xmlns="http://soap.sforce.com/2006/04/metadata">
    <customObject>true</customObject>
    <motif>Custom24: Building</motif>
</CustomTab>
"@

$fp = ""
foreach ($f in "Address__c","Bathrooms__c","Bedroom__c","City__c","Picture__c","Price__c","State__c","Zip__c") {
  $fp += "    <fieldPermissions><editable>true</editable><field>House__c.$f</field><readable>true</readable></fieldPermissions>`n"
}
W "$base\permissionsets\House_Access.permissionset-meta.xml" @"
$h
<PermissionSet xmlns="http://soap.sforce.com/2006/04/metadata">
$fp    <hasActivationRequired>false</hasActivationRequired>
    <label>House Access</label>
    <objectPermissions>
        <allowCreate>true</allowCreate><allowDelete>true</allowDelete>
        <allowEdit>true</allowEdit><allowRead>true</allowRead>
        <modifyAllRecords>false</modifyAllRecords><object>House__c</object>
        <viewAllRecords>false</viewAllRecords>
    </objectPermissions>
    <tabSettings><tab>House__c</tab><visibility>Visible</visibility></tabSettings>
</PermissionSet>
"@

Write-Host "Listo:" -ForegroundColor Green
Get-ChildItem "$obj\fields" | Select-Object Name