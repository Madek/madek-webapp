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
      And I am "Normin"

  # https://www.pivotaltracker.com/story/show/26706147
  @wip    
  Scenario: Specific order in which metadata context groups appear in the interface
    When I view a media entry
    Then the metadata context groups are in the following order:
      | order | name      |
      |     1 | Metadaten |
      |     2 | Kontexte  |

  # https://www.pivotaltracker.com/story/show/26706147
  @wip
  Scenario: Specific order in which metadata contexts appear inside of metadata context groups in the interface
    When I view a media entry
    Then the metadata contexts inside of "Metadaten" are in the following order:
      | order | name   |
      |     1 | Werk   |
      |     2 | Medium |
     And the metadata contexts inside of "Kontexte" are in the following order:
      | order | name                      |
      |     1 | Landschaftsvisualisierung |
      |     2 | Zett                      |

  # https://www.pivotaltracker.com/story/show/26706147
  @wip
  Scenario: Context groups are only displayed if the media entry is in a set that is assigned to a context and that context is in the admin interface assigned to the metadata context group
    Given a media entry with a full set of metadata in all available contexts
      And a set called "Planets" with the context "Astronomical Metadata"
      And the media entry is in the set "Planets"      
     When I view the media entry
     Then I see the metadata context group "Scientific Metadata"
      And I do not see the metadata context group "Humanities"
