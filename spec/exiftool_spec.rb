# -*- encoding : utf-8 -*-
require 'spec_helper'


describe Exiftool do

  it "should respond to parse_metadata" do
    Exiftool.respond_to?(:parse_metadata).should == true
  end

  it "should return fiels with files of asked for" do
    res = Exiftool.parse_metadata "features/data/images/berlin_wall_01.jpg" ,["File"]
    res.flatten.grep(/File/).should_not be_empty
  end

  it "should respond to extract_madek_subjective_metadata" do
    Exiftool.respond_to?(:extract_madek_subjective_metadata).should == true
  end

  it "should extract madek subjective metadata" do
    res = Exiftool.extract_madek_subjective_metadata "features/data/images/date_should_be_from_to_may.jpg", "image"
    res[0][0][0].match(/Author/).should be
    res[0][0][1].match(/Buser/).should be
  end


  it "should respond to filter_unwanted_fields" do
    Exiftool.respond_to?(:filter_unwanted_fields).should == true
  end


  it "should effectively filter" do

    arr =  [ 
      [["XMP-madek:Author", "Buser, Monika"], ["XMP-madek:PortrayedObjectDates", "01.05.2011 - 31.05.2011"] ], 
      [["XMP-dc:Creator", "Buser, Monika"], ["XMP-dc:Description", "Diplomarbeit Vertiefung Fotografie, \"Frau-Sein\""], ["XMP-dc:Rights", "Zürcher Hochschule der Künste"], ["XMP-dc:Subject", ["Diplomarbeit", "Porträt", "Selbstporträt", "Schweiz"]], ["XMP-dc:Title", "Frau-Sein"] ], 
      [["XMP-photoshop:CaptionWriter", "Armbruster, Linda"], ["XMP-photoshop:Credit", "Departement Kunst & Medien, Vertiefung Fotografie"]], 
      [], 
      [["XMP-xmpRights:Marked", true], ["XMP-xmpRights:UsageTerms", "Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden."], ["XMP-xmpRights:WebStatement", "http://www.copyright.ch"]], 
      [], 
      [["XMP-photoshop:ICCProfileName","DELETE_ME"] ] ]

      (Exiftool.filter_unwanted_fields arr,"image").flatten.find{ |f| f =~ /DELETE_ME/ }.should_not be

  end

  it "should extract metadata from PDF files" do
    res = Exiftool.parse_metadata "features/data/files/test_pdf_for_metadata.pdf", ["PDF"]
    fields_that_should_exist = ["PDF:Creator", "PDF:Keywords", "PDF:Title"]
    fields_that_should_exist.each do |f|
      res.flatten.grep(f).should_not be_empty
    end
  end


end

