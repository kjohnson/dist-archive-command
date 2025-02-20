Feature: Generate a distribution archive of a project

  Scenario: Generates a ZIP archive by default
    Given a WP install

    When I run `wp scaffold plugin hello-world`
    Then the wp-content/plugins/hello-world directory should exist
    And the wp-content/plugins/hello-world/hello-world.php file should exist
    And the wp-content/plugins/hello-world/.travis.yml file should exist
    And the wp-content/plugins/hello-world/bin directory should exist

    When I run `wp dist-archive wp-content/plugins/hello-world`
    Then STDOUT should be:
      """
      Success: Created hello-world.0.1.0.zip
      """
    And STDERR should be empty
    And the wp-content/plugins/hello-world.0.1.0.zip file should exist

    When I run `wp plugin delete hello-world`
    Then the wp-content/plugins/hello-world directory should not exist

    When I run `wp plugin install wp-content/plugins/hello-world.0.1.0.zip`
    Then the wp-content/plugins/hello-world directory should exist
    And the wp-content/plugins/hello-world/hello-world.php file should exist
    And the wp-content/plugins/hello-world/.travis.yml file should not exist
    And the wp-content/plugins/hello-world/bin directory should not exist

  Scenario: Generates a tarball archive with a flag
    Given a WP install

    When I run `wp scaffold plugin hello-world`
    Then the wp-content/plugins/hello-world directory should exist
    And the wp-content/plugins/hello-world/hello-world.php file should exist
    And the wp-content/plugins/hello-world/.travis.yml file should exist
    And the wp-content/plugins/hello-world/bin directory should exist

    When I run `wp dist-archive wp-content/plugins/hello-world --format=targz`
    Then STDOUT should be:
      """
      Success: Created hello-world.0.1.0.tar.gz
      """
    And STDERR should be empty
    And the wp-content/plugins/hello-world.0.1.0.tar.gz file should exist

    When I run `wp plugin delete hello-world`
    Then the wp-content/plugins/hello-world directory should not exist

    When I try `cd wp-content/plugins/ && tar -zxvf hello-world.0.1.0.tar.gz`
    Then the wp-content/plugins/hello-world directory should exist
    And the wp-content/plugins/hello-world/hello-world.php file should exist
    And the wp-content/plugins/hello-world/.travis.yml file should not exist
    And the wp-content/plugins/hello-world/bin directory should not exist

  Scenario: Generate a ZIP archive with a custom name
    Given a WP install

    When I run `wp scaffold plugin hello-world`
    Then the wp-content/plugins/hello-world directory should exist
    And the wp-content/plugins/hello-world/hello-world.php file should exist
    And the wp-content/plugins/hello-world/.travis.yml file should exist
    And the wp-content/plugins/hello-world/bin directory should exist

    When I run `wp dist-archive wp-content/plugins/hello-world hello-world.zip`
    Then STDOUT should be:
      """
      Success: Created hello-world.zip
      """
    And the wp-content/plugins/hello-world.zip file should exist
    And the wp-content/plugins/hello-world.0.1.0.zip file should not exist

  Scenario: Generate a ZIP archive to a relative path without specifying the filename
    Given a WP install

    When I run `wp scaffold plugin hello-world`
    Then the wp-content/plugins/hello-world directory should exist
    And the wp-content/plugins/hello-world/hello-world.php file should exist
    And the wp-content/plugins/hello-world/.travis.yml file should exist
    And the wp-content/plugins/hello-world/bin directory should exist

    When I run `wp dist-archive wp-content/plugins/hello-world wp-content`
    Then STDOUT should be:
      """
      Success: Created hello-world.0.1.0.zip
      """
    And the wp-content/hello-world.0.1.0.zip file should exist
    And the wp-content/plugins/hello-world.0.1.0.zip file should not exist

  Scenario: Generate a ZIP archive to a relative path with a specified filename
    Given a WP install

    When I run `wp scaffold plugin hello-world`
    Then the wp-content/plugins/hello-world directory should exist
    And the wp-content/plugins/hello-world/hello-world.php file should exist
    And the wp-content/plugins/hello-world/.travis.yml file should exist
    And the wp-content/plugins/hello-world/bin directory should exist

    When I run `mkdir subdir`
    Then the subdir directory should exist

    When I run `wp dist-archive wp-content/plugins/hello-world ./subdir/hello-world.zip`
    Then STDOUT should be:
        """
        Success: Created hello-world.zip
        """
    And STDERR should be empty
    And the {RUN_DIR}/subdir/hello-world.zip file should exist

  Scenario: Generate a ZIP archive to an absolute path without specifying the filename
    Given a WP install

    When I run `wp scaffold plugin hello-world`
    Then the wp-content/plugins/hello-world directory should exist
    And the wp-content/plugins/hello-world/hello-world.php file should exist
    And the wp-content/plugins/hello-world/.travis.yml file should exist
    And the wp-content/plugins/hello-world/bin directory should exist

    When I run `wp dist-archive wp-content/plugins/hello-world {RUN_DIR}/wp-content/`
    Then STDOUT should be:
        """
        Success: Created hello-world.0.1.0.zip
        """
    And STDERR should be empty
    And the {RUN_DIR}/wp-content/hello-world.0.1.0.zip file should exist

  Scenario: Generate a ZIP archive using version number in composer.json
    Given an empty directory
    And a foo/.distignore file:
      """
      .gitignore
      .distignore
      features/
      """
    And a foo/features/sample.feature file:
      """
      Testing
      """
    And a foo/composer.json file:
      """
      {
          "name": "runcommand/profile",
          "description": "Quickly identify what's slow with WordPress.",
          "homepage": "https://runcommand.io/wp/profile/",
          "version": "0.2.0-alpha"
      }
      """

    When I run `wp dist-archive foo`
    Then STDOUT should be:
      """
      Success: Created foo.0.2.0-alpha.zip
      """
    And the foo.0.2.0-alpha.zip file should exist

    When I run `rm -rf foo`
    Then the foo directory should not exist

    When I run `unzip foo.0.2.0-alpha.zip`
    Then the foo directory should exist
    And the foo/composer.json file should exist
    And the foo/.distignore file should not exist
    And the foo/features/sample.feature file should not exist

  Scenario Outline: Ignores hidden files in subdirectories
    Given an empty directory
    And a foo/.distignore file:
      """
      .DS_Store
      """
    And a foo/test.php file:
      """
      <?php
      echo 'Hello world;';
      """
    And a foo/test-dir/test.php file:
      """
      <?php
      echo 'Hello world;';
      """
    And a foo/test-dir/.DS_Store file:
      """
      Bad!
      """

    When I run `wp dist-archive foo --format=<format>`
    Then STDOUT should be:
      """
      Success: Created foo.<extension>
      """
    And the foo.<extension> file should exist

    When I run `rm -rf foo`
    Then the foo directory should not exist

    When I try `<extract> foo.<extension>`
    Then the foo directory should exist
    And the foo/test.php file should exist
    And the foo/test-dir/test.php file should exist
    And the foo/test-dir/.DS_Store file should not exist

    Examples:
      | format  | extension | extract   |
      | zip     | zip       | unzip     |
      | targz   | tar.gz    | tar -zxvf |

  Scenario Outline: Ignores files specified with absolute path and not similarly named files
	Given an empty directory
	And a foo/.distignore file:
      """
      /maybe-ignore-me.txt
      """
	And a foo/test.php file:
      """
      <?php
      echo 'Hello world;';
      """
	And a foo/test-dir/test.php file:
      """
      <?php
      echo 'Hello world;';
      """
	And a foo/maybe-ignore-me.txt file:
      """
      Ignore
      """
	And a foo/test-dir/maybe-ignore-me.txt file:
      """
      Do not ignore
      """
	And a foo/test-dir/foo/maybe-ignore-me.txt file:
      """
      Do not ignore
      """

	When I run `wp dist-archive foo --format=<format> --plugin-dirname=<plugin-dirname>`
	Then STDOUT should be:
      """
      Success: Created <plugin-dirname>.<extension>
      """
	And the <plugin-dirname>.<extension> file should exist

	When I run `rm -rf foo`
	Then the foo directory should not exist

	When I run `rm -rf <plugin-dirname>`
	Then the <plugin-dirname> directory should not exist

	When I try `<extract> <plugin-dirname>.<extension>`
	Then the <plugin-dirname> directory should exist
	And the <plugin-dirname>/test.php file should exist
	And the <plugin-dirname>/test-dir/test.php file should exist
	And the <plugin-dirname>/maybe-ignore-me.txt file should not exist
	And the <plugin-dirname>/test-dir/maybe-ignore-me.txt file should exist
	And the <plugin-dirname>/test-dir/foo/maybe-ignore-me.txt file should exist

	Examples:
	  | format  | extension | extract   | plugin-dirname |
	  | zip     | zip       | unzip     | foo            |
	  | targz   | tar.gz    | tar -zxvf | foo            |
	  | zip     | zip       | unzip     | bar            |
	  | targz   | tar.gz    | tar -zxvf | bar2           |

  Scenario Outline: Correctly ignores hidden files when specified in distignore
    Given an empty directory
    And a foo/.distignore file:
      """
      .*
      """
    And a foo/.hidden file:
      """
      Ignore
      """
    And a foo/test-dir/.hidden file:
      """
      Ignore
      """
    And a foo/not.hidden file:
      """
      Do not ignore
      """
    And a foo/test-dir/not.hidden file:
      """
      Do not ignore
      """

    When I run `wp dist-archive foo --format=<format> --plugin-dirname=<plugin-dirname>`
    Then STDOUT should be:
      """
      Success: Created <plugin-dirname>.<extension>
      """
    And the <plugin-dirname>.<extension> file should exist

    When I run `rm -rf foo`
    Then the foo directory should not exist

    When I run `rm -rf <plugin-dirname>`
    Then the <plugin-dirname> directory should not exist

    When I try `<extract> <plugin-dirname>.<extension>`
    Then the <plugin-dirname> directory should exist
    And the <plugin-dirname>/.hidden file should not exist
    And the <plugin-dirname>/not.hidden file should exist
    And the <plugin-dirname>/test-dir/hidden file should not exist
    And the <plugin-dirname>/test-dir/not.hidden file should exist

    Examples:
      | format  | extension | extract   | plugin-dirname |
      | zip     | zip       | unzip     | foo            |
      | targz   | tar.gz    | tar -zxvf | foo            |
      | zip     | zip       | unzip     | bar3           |
      | targz   | tar.gz    | tar -zxvf | bar4           |

  Scenario: Create directories automatically if requested
    Given a WP install

    When I run `wp scaffold plugin hello-world`
    Then the wp-content/plugins/hello-world directory should exist
    And the wp-content/plugins/hello-world/hello-world.php file should exist
    And the wp-content/plugins/hello-world/.travis.yml file should exist
    And the wp-content/plugins/hello-world/bin directory should exist

    When I try `wp dist-archive wp-content/plugins/hello-world {RUN_DIR}/some/nested/folder/hello-world.zip`
    Then STDERR should contain:
      """
      Error: Target directory does not exist
      """

    When I run `wp dist-archive --create-target-dir wp-content/plugins/hello-world {RUN_DIR}/some/nested/folder/hello-world.zip`
    Then STDOUT should be:
      """
      Success: Created hello-world.zip
      """
    And STDERR should be empty
    And the {RUN_DIR}/some/nested/folder/hello-world.zip file should exist

  Scenario: Allow specifying the current directory for input using dot
    Given a WP install

    When I run `wp scaffold plugin hello-world`
    Then the wp-content/plugins/hello-world directory should exist
    And the wp-content/plugins/hello-world/hello-world.php file should exist
    And the wp-content/plugins/hello-world/.travis.yml file should exist
    And the wp-content/plugins/hello-world/bin directory should exist

    When I run `wp dist-archive . {RUN_DIR}/hello-world.zip` from 'wp-content/plugins/hello-world'
    Then STDOUT should be:
        """
        Success: Created hello-world.zip
        """
    And STDERR should be empty
    And the {RUN_DIR}/hello-world.zip file should exist

  Scenario: Use plugin parent directory for output unless otherwise specified
    Given a WP install

    When I run `wp scaffold plugin hello-world`
    Then the wp-content/plugins/hello-world directory should exist
    And the wp-content/plugins/hello-world/hello-world.php file should exist
    And the wp-content/plugins/hello-world/.travis.yml file should exist
    And the wp-content/plugins/hello-world/bin directory should exist

    When I run `wp dist-archive . hello-world.zip` from 'wp-content/plugins/hello-world'
    Then STDOUT should be:
        """
        Success: Created hello-world.zip
        """
    And STDERR should be empty
    And the {RUN_DIR}/wp-content/plugins/hello-world.zip file should exist

  Scenario: Use current directory for output when specified
    Given a WP install

    When I run `wp scaffold plugin hello-world`
    Then the wp-content/plugins/hello-world directory should exist
    And the wp-content/plugins/hello-world/hello-world.php file should exist
    And the wp-content/plugins/hello-world/.travis.yml file should exist
    And the wp-content/plugins/hello-world/bin directory should exist

    When I run `wp dist-archive . ./hello-world.zip` from 'wp-content/plugins/hello-world'
    Then STDOUT should be:
        """
        Success: Created hello-world.zip
        """
    And STDERR should be empty
    And the {RUN_DIR}/wp-content/plugins/hello-world/hello-world.zip file should exist

  Scenario: Allow specifying the current directory without filename for output using dot
    Given a WP install

    When I run `wp scaffold plugin hello-world`
    Then the wp-content/plugins/hello-world directory should exist
    And the wp-content/plugins/hello-world/hello-world.php file should exist
    And the wp-content/plugins/hello-world/.travis.yml file should exist
    And the wp-content/plugins/hello-world/bin directory should exist

    When I run `wp dist-archive wp-content/plugins/hello-world .`
    Then STDOUT should be:
        """
        Success: Created hello-world.0.1.0.zip
        """
    And STDERR should be empty
    And the {RUN_DIR}/hello-world.0.1.0.zip file should exist

  Scenario: Generates an archive with another name using the plugin-dirname flag
    Given a WP install

    When I run `wp scaffold plugin hello-world`
    Then the wp-content/plugins/hello-world directory should exist
    And the wp-content/plugins/hello-world/hello-world.php file should exist
    And the wp-content/plugins/hello-world/.travis.yml file should exist
    And the wp-content/plugins/hello-world/bin directory should exist

    When I run `wp dist-archive wp-content/plugins/hello-world --plugin-dirname=foobar-world`
    Then STDOUT should be:
        """
        Success: Created foobar-world.0.1.0.zip
        """
    And STDERR should be empty
    And the wp-content/plugins/foobar-world.0.1.0.zip file should exist

    When I run `wp plugin delete hello-world`
    Then the wp-content/plugins/hello-world directory should not exist

    When I run `wp plugin install wp-content/plugins/foobar-world.0.1.0.zip`
    Then the wp-content/plugins/foobar-world directory should exist
    And the wp-content/plugins/foobar-world/hello-world.php file should exist

  Scenario: Finds the version tag even if ill-formed
    Given a WP install

    When I run `wp scaffold plugin hello-world`
    Then the wp-content/plugins/hello-world directory should exist
    And the wp-content/plugins/hello-world/hello-world.php file should exist
    And the wp-content/plugins/hello-world/.travis.yml file should exist
    And the wp-content/plugins/hello-world/bin directory should exist

    When I run `awk '{sub("\\* Version","Version",$0); print}' {RUN_DIR}/wp-content/plugins/hello-world/hello-world.php > hello-world.tmp && mv hello-world.tmp {RUN_DIR}/wp-content/plugins/hello-world/hello-world.php`
    Then STDERR should be empty
    When I run `awk '{sub("0.1.0","0.2.0",$0); print}' {RUN_DIR}/wp-content/plugins/hello-world/hello-world.php > hello-world.tmp && mv hello-world.tmp {RUN_DIR}/wp-content/plugins/hello-world/hello-world.php`
    Then STDERR should be empty

    When I run `wp dist-archive wp-content/plugins/hello-world`
    Then STDOUT should be:
      """
      Success: Created hello-world.0.2.0.zip
      """
    And STDERR should be empty
    And the wp-content/plugins/hello-world.0.2.0.zip file should exist

    When I run `wp plugin delete hello-world`
    Then the wp-content/plugins/hello-world directory should not exist

    When I run `wp plugin install wp-content/plugins/hello-world.0.2.0.zip`
    Then the wp-content/plugins/hello-world directory should exist
    And the wp-content/plugins/hello-world/hello-world.php file should exist
    And the wp-content/plugins/hello-world/.travis.yml file should not exist
    And the wp-content/plugins/hello-world/bin directory should not exist

Scenario: Avoids recursive symlink
    Given a WP install in wordpress
    And a .distignore file:
      """
      wp-content
      wordpress
      """

    When I run `mkdir -p wp-content/plugins`
    Then STDERR should be empty

    When I run `rm -rf wordpress/wp-content`
    Then STDERR should be empty

    When I run `ln -s {RUN_DIR}/wp-content {RUN_DIR}/wordpress/wp-content`
    Then STDERR should be empty

    When I run `wp scaffold plugin hello-world --path=wordpress`
    Then the wp-content/plugins/hello-world directory should exist
    And the wp-content/plugins/hello-world/hello-world.php file should exist

    When I run `mv wp-content/plugins/hello-world/hello-world.php .`
    Then STDERR should be empty

    When I run `rm -rf wp-content/plugins/hello-world`
    Then STDERR should be empty

    When I run `ln -s {RUN_DIR} {RUN_DIR}/wp-content/plugins/hello-world`
    Then STDERR should be empty
    And the wp-content/plugins/hello-world/hello-world.php file should exist

    When I run `wp dist-archive . --plugin-dirname=$(basename "{RUN_DIR}")`
    Then STDERR should be empty

  Scenario: Warns but continues when no distignore file is present
    Given an empty directory
    And a test-plugin/test-plugin.php file:
      """
      <?php
      /**
       * Plugin Name:       Test Plugin
       * Version:           1.0.0
       */
      """

    When I try `wp dist-archive test-plugin`
    Then STDERR should contain:
      """
      No .distignore file found. All files in directory included in archive.
      """
    And the test-plugin.1.0.0.zip file should exist
