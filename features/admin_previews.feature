Feature: Managing Previews

  As a MAdeK admin, sometimes I need to regenerate the preview images that are attached to resources.

  Scenario: Regenerating previews for still images (JPEG, TIFF...)
    Given I am signed-in as "Adam"
    And I have a media_entry of type image including previews
    And All previews are deleted for the media_entry
    And I go to the page of the media_entry
    And I click on the link "Weitere Aktionen"
    And I click on the link "MediaEntry in the Admin Interface"
    And I click on the link "MediaFile:"
    Then I can see that there are no previews 
    When I click on the link "Recreate Thumbnails"
    Then I can see that there are several previews
   
  Scenario: Reencode previews for audio/video
    Given I am signed-in as "Adam"
    And I have a media_entry of type video 
    And I go to the page of the media_entry
    And I click on the link "Weitere Aktionen"
    And I click on the link "MediaEntry in the Admin Interface"
    And I click on the link "MediaFile:"
    And I remember the number of ZencoderJobs
    When I click on the link "Reencode"
    And A new ZencoderJob has been added
    And The state of the newest ZencoderJob is "submitted"
   
