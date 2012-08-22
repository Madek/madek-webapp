Feature: Upload
  
  # https://www.pivotaltracker.com/story/show/24559359 -> Datierung aus Kameradatum (EXIF/IPTC) übernehmen (Erstellungsdatum)
  Scenario: Extracting the camera date into metadata
    Given I am pending
    When I upload a file
    Then I want to have the date the camera took the picture on as the creation date


# uncomment this when we we merge next again -- this was added due to a pull request from istrebel that
# seems to have included this.
# @javascript
# Scenario: Uploading an MP3 file
#   Given I am "Normin"
#   When I upload the file "features/data/files/shit_in_my_head.mp3" relative to the Rails directory 
#   #When I upload the file "features/data/images/berlin_wall_01.jpg" relative to the Rails directory 
#   And I go to the upload edit
#   And I fill in the metadata for entry number 1 as follows:
#   |label    |value                       |
#   |Rechte|Some Random Stuff             |
#   And I follow "weiter..."
#   And I follow "Import abschliessen"
#   And I go to the media entries
#   And I click the media entry titled "Shit in my Head"
#   Then I should see "Shit in my Head"
#   # TODO: Extract this to 'Rechte' or 'Autor/in'
#   #And I should see "Bit-Tuner and Kurt Kuene"
