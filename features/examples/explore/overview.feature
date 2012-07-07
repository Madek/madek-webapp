Feature: Overview
  
  Background: Load the example data and personas
    Given I have set up the world a little

  # https://www.pivotaltracker.com/story/show/21438575
  Scenario: Displaying the appropriate placeholder icon for a file that can't be previewed
    Then each of the following media types has its own representing icon according to the mappings in the file "config/mime_icons.yml"

  Scenario: Thumbnail for media resources with pdf mime type
    When I see a thumbnail of a media resource with pdf mime type
    Then I see the first page of that pdf as thumbnail image

  Scenario: Failing to extract a thumbnail from broken PDF files
    When I upload a file with pdf mime type
     And that file is damaged
     And I see a thumbnail of a media resource with pdf mime type
    Then I see a thumbnail placeholder for pdf

  Scenario: Displaying thumbnail frames for pdf in list view
    Given I see a list of resources
      And one of the resources is a pdf
     When I switch to the list view
     Then I see that the pdf thumbnail is surrounded by a document frame 
     When I switch to the miniature view
     Then I see that the pdf thumbnail is surrounded by a document frame 
     When I switch to the grid view
     Then I see that the pdf thumbnail is surrounded by a document frame 