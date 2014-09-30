Feature: project gem

  To test that dependencies are installed correctly in a clean gemset, it is necessary to be able to install the project
  under test's gem into the clean gemset while the dependencies are fetched using normal procedures, like
  'gem install'.

  Scenario:
    When I build gem from project's "aruba.gemspec"
    Then a file matching %r<aruba-.*\.gem> should exist

  @gem-install
  Scenario:
    Given I build gem from project's "aruba.gemspec"
    And I'm using a clean gemset "aruba-installer"
    And I install latest local "aruba" gem
    When I run `gem list`
    Then the output from "gem list" should contain "aruba"