Feature: Upload

  Scenario: Uploading large files
    When I upload file larger than 2 GB
    Then the file is stored in the system
