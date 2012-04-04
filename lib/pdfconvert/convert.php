#!/usr/bin/php
<?
#print_r(get_loaded_extensions());

error_reporting(E_ERROR);

try {

	# Be sure to export LD_LIBRARY_PATH=/opt/openoffice.org2.4_sdk/linux/lib:/opt/openoffice.org2.4/program/
	# /opt/openoffice.org2.4/program/soffice "-accept=socket,host=localhost,port=8100;urp;StarOffice.ServiceManager" &	

	// # Start OpenOffice to listen on port 8100
	// $soffice_proc = system("/opt/openoffice.org2.4/program/soffice '-accept=socket,host=localhost,port=8100;urp;' &"); //,'r');

	
	// Other helpful info here:
	// http://puno.sourceforge.net/install.html


	# Create and modify document
	echo "  Creating new DocComponent\n";
	$doc = newDocComponent("file://$argv[1]");

	# Add header text
	echo "  Adding header text\n";
	addHeaderText($doc, $argv[2]);
	
	# Export as PDF
	echo "  Exporting PDF file\n";
	exportToPdf($doc,"file://$argv[3]");

	# Dispose of document
	$doc->dispose();

// 	# Close the OpenOffice listener
//	pclose($soffice_proc);
	
	# Report back to user
	echo "  Successfully generated PDF file.\n";

} catch (Exception $e) {
	
	die($e->getMessage());
	
}


###################################################################


// Loads an Office document from the specified URL
function newDocComponent($url) {
	$x_component_loader=get_remote_xcomponent("uno:socket,host=localhost,port=8100;urp;StarOffice.ServiceManager","com.sun.star.frame.Desktop");
	
    $load_props=array();
    $x_component=$x_component_loader->loadComponentFromURL($url,"_default",0,$load_props);
    return $x_component;
}


// Exports the supplied document to PDF using the URL specified
function exportToPdf($doc_component, $url) {
	$store_props=array();
    $store_props[0]=create_struct("com.sun.star.beans.PropertyValue");
    $store_props[0]->Name="FilterName";
    $store_props[0]->Value = "writer_pdf_Export"; 

    $doc_component->storeToURl($url,$store_props);
}


// Adds the supplied text to the top of the document
function addHeaderText($doc, $new_text) {
	$x_page_style = $doc->createInstance("com.sun.star.style.PageStyle");
	$x_header = $doc->getStyleFamilies()->getByName("PageStyles")->getByName("Standard");
	$x_header->setPropertyValue("HeaderIsOn", true);
	$header_text = $x_header->getPropertyValue("HeaderText");
	$header_text->setString($new_text);
}


?>
