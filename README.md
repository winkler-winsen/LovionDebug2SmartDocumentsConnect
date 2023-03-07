# LovionDebug2SmartDocumentsConnect
Converts Lovion EXPLORE debug information to elemets to import into SmartDocumentsConnect ExportConfigs

Um Lovion mit Smart Documents verbinden zu können, muß für jede Vorlage eine ExportConfig XML Datei erstellt werden. Für mich hat es keinen Sinn ergeben, das alles manuell mittels Copy'n'Paste zu machen, daher habe ich einige Zeit in dieses Powershell Script gesteckt. Mit diesem kann man in einem Rutsch alle für Vorlagen relevanten Felder für die ExportConfigs XML vorbereiten. Ich verwende ALLE Felder des zugehörigen RwoTypes und ggf. zusätzlich der weiterverwendeten Objekte.

## Example Lovion EXPLORE Debug Ctrl+Alt+Shift+F11
```
Id: 123456_756_45569
RwoTypeName: "Example" (example)
RwoTypeName (inherited): "InheritExpample" (lst_object_1)
RwoTypeName (inherited): "InheritExample" (lst_rwo_0)
RwoProviderId: Example
ConnectionString: Data Source=rubarubaruba


# Visible Fields
Number (objektnummer)                                                                : 123456 756 45569 (String(32)|System.String|)
Place (municipality)                                                                 : Placename (String(255)|System.String|)
Street (street)                                                                      : Street (String(255)|System.String|)
House Number (house_number)                                                          : 12a (String(32)|System.String|)
Contact (person) (cm_person_in_status_role)                                          : 54 Objekte
Eigentümer (hist.) (eigentuemer)                                                     : 0 Objekte
Ansprechpartner (related_person)                                                     : 0 Objekte
```

## Example ExportConfigs XML
```xml
<?xml version="1.0" encoding="utf-8"?>
<TemplateConfiguration xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation=" TemplateConfiguration.xsd">
<LovionFileFormat>
	<Version minRelease="6.6.5" />
</LovionFileFormat>
<TemplateGroup id="40F4F1B848BF427A91FFC3FD43AB1868" externalName="82.4">
	<Template id="16A72D3231E64BE389D4EC1F7D4961FF" externalName="82.4 Wesentliche Änderung_2022" mode="wizard" outputFilePathWithoutExtension="Wesentliche Änderung_2022 {entsorgungsflaeche/@objektnummer}-Maßnahme-{@cm_process_number}">
		<SupportedRwoTypes>
			<RwoType rwoProviderID="AssetDisposal" rwoTypeName="cm_waste_water_connection" />
		</SupportedRwoTypes>
		<Placeholders>
			<GroupMapping placeholder="Example">
<!-- place output here -->      
			</GroupMapping>
		</Placeholders>
	</Template>
	</TemplateGroup>
</TemplateConfiguration>
```
