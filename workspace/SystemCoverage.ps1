$ie = new-object -comobject InternetExplorer.Application
$ie.visible = $true

$ie.addressbar=$false

$ie.menubar=$false
$ie.toolbar=$false
$ie.top = 200; $ie.Left = 100
$ie.navigate("file:///R:/modules/doc/covhtmlreports/SystemCoverage/pages/__frametop.htm")