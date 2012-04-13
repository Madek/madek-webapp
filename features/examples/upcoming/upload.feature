  # https://www.pivotaltracker.com/story/show/24559359 -> Datierung aus Kameradatum (EXIF/IPTC) übernehmen (Erstellungsdatum)
  Scenario: Extracting the camera date into metadata
    When I upload a file
    Then I want to have the date the camera took the picture on as the creation date

