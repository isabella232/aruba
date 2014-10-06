Feature: rvm gemsets

  By default Aruba uses the gemset of the project calling cucumber, but sometime, such as to test installation script,
  a clean gemset is necessary that doesn't have the gems from the project under test in it.

  Scenario:
    Given I create a gemset "created"
    When I run `rvm gemset list`
    Then the output should contain "created"

  Scenario:
    Given I create a gemset "used"
    And I use gemset "used"
    And I run `rvm current`
    Then the output from "rvm current" should contain "used"

  Scenario:
    Given I'm using a clean gemset "clean-gemset"
    Then I run `rvm current`
    Then the output from "rvm current" should contain "clean-gemset"

  Scenario:
    Given I'm using a clean gemset "arubaless"
    Then I run `gem list`
    Then the output from "gem list" should not contain "aruba"

