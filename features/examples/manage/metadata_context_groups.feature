Feature: Metadata context groups
  As an administrator of the system
  I want to create and manage metadata contexts
  So that metadata context is grouped into logical entities (metadata groups).

  Example: We group "Astronomical Metadata" and "Physics Metadata" into a metadata
  context group called "Scientific Metadata". Then these two contexts appear under the
  heading "Scientific Metadata" everywhere in the interface, giving users good overview.
  
  Background: Load the example data and personas
    Given I have set up the world
      And personas are loaded
      And I am "Liselotte"

  # https://www.pivotaltracker.com/story/show/26706147
  @javascript
  Scenario: Specific order in which metadata context groups appear in the interface
    When I visit a media entry with individual contexts
    Then the metadata context groups are in the following order:
      | order | name          |
      |     1 | Metadaten     |
      |     2 | Kontexte      |
      |     3 | Weitere Daten |

  # https://www.pivotaltracker.com/story/show/26706147
  @javascript
  Scenario: Specific order in which metadata contexts appear inside of metadata context groups in the interface
    When I visit a media entry with the following individual contexts: 
      | order | name                      |
      |     1 | Landschaftsvisualisierung |
      |     2 | Zett                      |
    Then the metadata contexts inside of "Metadaten" are in the following order:
      | order | name   |
      |     1 | Werk   |
      |     2 | Medium |
     And the metadata contexts inside of "Kontexte" are in the following order:
      | order | name                      |
      |     1 | Landschaftsvisualisierung |
      |     2 | Zett                      |

  # https://www.pivotaltracker.com/story/show/26706147
  @javascript
  Scenario: Context groups are only displayed if they have contexts that are associated to a set which the media entry is inheritancing the meta context from
    When I visit a media entry with individual contexts
    Then I see the context group "Kontexte"
     And I see the context "Landschaftsvisualisierung"
     And I do not see the context "Zett"

  # https://www.pivotaltracker.com/story/show/24969841
  @javascript
  Scenario: Display google map when a media entry has GPS meta data 
    When I visit a media entry without GPS meta data
    Then I do not see the context group "Karte"
    When I visit a media entry with GPS meta data
    Then I see the context group "Karte"
    When I expande the context group "Karte"
    Then I see the the google map
