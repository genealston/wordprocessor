require 'zipruby'
require 'nokogiri'
require 'fileutils'

class OfficeOpenXML
  
  def self.translate(xslt, template, xml, newdoc)
    new(xslt, template, xml, newdoc).translate
  end

  def initialize(xslt, template, xml, newdoc)
    #Store the instance variables
    @xslt, @template, @xml, @newdoc = xslt, template, xml, newdoc
  end

  def translate
    #get the existing document
    existing_xml = get_from_tempate("word/document.xml")
    #find the body node
    body_node = existing_xml.root.xpath("w:body", {"w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main"}).first
    #remove all current nodes on the body (ie clear doc)
    body_node.children.unlink
    #For each node on the new xml add it to the current xml.
    new_xml.xpath("*/w:body", {"w" => "http://schemas.openxmlformats.org/wordprocessingml/2006/main"}).first.children.each do |child|
      body_node.add_child(child)
    end
    #compress the result to a docx
    compress(existing_xml)
  end

  def get_from_tempate(filename)
    #retrieve the document from the template doc
    xml = Zip::Archive.open(@template) do |zipfile|
      zipfile.fopen(filename).read
    end
    #parse the resulting file into the Nokogiri xml doc
    Nokogiri::XML.parse(xml)
  end

  def new_xml
    #transform the xml values to fit out word document.
    stylesheet_doc.transform(Nokogiri::XML.parse(File.open(@xml)))
  end

  def compress(newXML)
    #Copy the template to the new document
    FileUtils.copy(@template, @newdoc)
    #Open the zip archive
    Zip::Archive.open(@newdoc, Zip::CREATE) do |zipfile|
      #Replace the document.xml with our new xml
      zipfile.add_or_replace_buffer('word/document.xml', newXML.to_s)
    end
  end

  def stylesheet_doc
    #Parse the xslt into the Nokogiri XSLT
    Nokogiri::XSLT.parse(File.open(@xslt))
  end
end
