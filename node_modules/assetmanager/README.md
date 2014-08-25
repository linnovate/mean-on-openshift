[![NPM](https://nodei.co/npm/assetmanager.png?downloads=true)](https://nodei.co/npm/assetmanager/)

node-assetmanager
=================

Asset manager easily allows you to switch between development and production css
and js files in your templates by managing them in a single json file that's
still compatible with grunt cssmin and uglify. A working demo/implimentation of
this can been seen in [MEAN Stack](https://github.com/linnovate/mean).


##Usage
To use [assetmanager](https://www.npmjs.org/package/assetmanager), cd into your
project directory and install assetmanager with npm.


```
$ cd /to/project/directory
$ npm install assetmanager --save
```

Setup an external json asset configuration file that holds your development and
production css and js files. The format of this file can be in either
[files object format](http://gruntjs.com/configuring-tasks#files-object-format),
or [files array format](http://gruntjs.com/configuring-tasks#files-array-format).

You may also add external resources, however these entries should be 1-to-1 key value
pairs. External resources will not cause issues with grunt cssmin or uglify,
they will simply be treated as empty resources and thus ignored.

###Files Object Format
[Files object format](http://gruntjs.com/configuring-tasks#files-object-format)
consists of file groups (main, secondary, etc.) that contain file types (css,
js).  Each file type has a destination file mapped to a list of files of which
the destination file is composed in production mode.

In the [assets file](#assets.json) below, the main js files might be passed
to [grunt-contrib-uglify](https://github.com/gruntjs/grunt-contrib-uglify).  The
output from that Grunt task would be in "public/build/js/main.min.js" - in
production mode, assetmanager will place that filename in the list of assets in
_assets.main.js_.  In debug mode, assetmanager would flatten the lists of
js source files, placing the flattened list in _assets.main.js_.  This makes
original, uncompressed js source files available in the browser during
debugging.

####assets.json

```
{
	"main": {
		"css": {
			"public/build/css/main.min.css": [
				"public/lib/bootstrap/dist/css/bootstrap.css",
				"public/css/**/*.css"
			]
		},
		"js": {
			"//cdnjs.cloudflare.com/ajax/libs/underscore.js/1.6.0/underscore-min.js": "//cdnjs.cloudflare.com/ajax/libs/underscore.js/1.6.0/underscore.js",
			"public/build/js/main.min.js": [
				"public/lib/angular/angular.js",
				"public/lib/angular-cookies/angular-cookies.js",
				"public/lib/angular-resource/angular-resource.js",
				"public/lib/angular-ui-router/release/angular-ui-router.js",
				"public/lib/angular-bootstrap/ui-bootstrap.js",
				"public/lib/angular-bootstrap/ui-bootstrap-tpls.js",
				"public/js/**/*.js"
			]
		}
	},
	"secondary": {
		"css": {
			"public/build/css/secondary.min.css": [
				"public/css/**/*.css"
			]
		},
		"js": {
			"public/build/js/secondary.min.js": [
				"public/js/**/*.js"
			]
		}
	}
}
```

This way in your `gruntfile` you can easily import the same `assets.json` config
file and plop in the respective values for css and js.

####gruntfile.js

```
'use strict';

module.exports = function(grunt) {
	// Project Configuration
	grunt.initConfig({
		assets: grunt.file.readJSON('config/assets.json'),
		uglify: {
			main: {
				options: {
					mangle: true,
					compress: true
				},
				files: '<%= assets.main.js %>'
			},
			secondary: {
				files: '<%= assets.secondary.js %>'
			}
		},
		cssmin: {
			main: {
				files: '<%= assets.main.css %>'
			},
			secondary: {
				files: '<%= assets.secondary.css %>'
			}
		}
	});

	//Load NPM tasks
	grunt.loadNpmTasks('grunt-contrib-cssmin');
	grunt.loadNpmTasks('grunt-contrib-uglify');

	//Making grunt default to force in order not to break the project.
	grunt.option('force', true);

	//Default task(s).
	grunt.registerTask('default', ['cssmin', 'uglify']);

};
```

###Files Array Format
[Files array format](http://gruntjs.com/configuring-tasks#files-array-format)
requires that each file type be an object with "src" (string array or string)
and "dest" (string) attributes.

This format allows configuring a single Grunt target with multiple destinations.
For example, perhaps you'd like to concatenate vendor minified css and js files
in production.  Both sets should have their own destination file as illustrated
in the assets configuration below with "vendorCss" and "vendorJs" file types.

####assets.js - array format
```
{
	"main": {
		"vendorCss": {
			"dest": "public/vendor_styles.min.css",
			"src": [
				"public/lib/bootstrap/dist/css/bootstrap.min.css",
				"public/lib/bootstrap/dist/css/bootstrap-theme.min.css"
			]
		},
		"vendorJs": {
			"dest": "public/lib.min.js",
			"src": [
				"public/lib/jquery/dist/jquery.min.js",
				"public/lib/bootstrap/dist/js/bootstrap.min.js",
				"public/lib/angular/angular.min.js",
				"public/lib/angular-resource/angular-resource.min.js",
				"public/lib/angular-cookies/angular-cookies.min.js",
				"public/lib/angular-ui-router/release/angular-ui-router.min.js",
				"public/lib/angular-bootstrap/ui-bootstrap-tpls.min.js"
			]
		},
		"publicCss": {
			"dest": "public/client_styles.min.css",
			"src": [
				"public/client/index/styles/common.css"
			]
		},
		"publicJs": {
			"dest": "public/client.min.js",
			"src": [
				"public/client/app.js",
				"public/client/**/*.js",
				"!public/client/init.js",
				"public/client/init.js",
				"!public/client/**/*Test.js"
			]
		},
		"underscore": {
			"dest": "//cdnjs.cloudflare.com/ajax/libs/underscore.js/1.6.0/underscore-min.js",
			"src": "//cdnjs.cloudflare.com/ajax/libs/underscore.js/1.6.0/underscore.js"
		}
	}
}
```

####gruntfile.js - array format
Note here that file array format requires the _files_ attribute be a list of
objects from the assets configuration:

```
	grunt.initConfig({
		pkg: grunt.file.readJSON('package.json'),
		assets: grunt.file.readJSON('client/assets-faf.json'),
		concat: {
			options: {
				separator: ';'
			},
			production: {
				files: [
					'<%= assets.main.vendorCss %>',
					'<%= assets.main.vendorJs %>'
				]
			}
		},
		cssmin: {
			options: {},
			production: {
				files: ['<%= assets.main.clientCss %>']
			}
		},
		uglify: {
			options: {},
			production: {
				files: ['<%= assets.main.clientJs %>']
			}
		}
	});

	grunt.loadNpmTasks('grunt-contrib-concat');
	grunt.loadNpmTasks('grunt-contrib-cssmin');
	grunt.loadNpmTasks('grunt-contrib-uglify');

	grunt.registerTask('production', [
		'concat:production',
		'cssmin:production',
		'uglify:production'
	]);

```

### Node.js Configuration
In your node app require `assetmanager`, the example below is partial code
from an express setup. Call `assetmanager.process` with your files from your
`assets.json` config file. Set the `debug` value to toggle between your
compressed files and your development files. You can also set the `webroot`
value so that when assetmanager processes your files it will change
`public/lib/angular/angular.js` to `/lib/angular/angular.js` so that everything
is relative to your webroot.

For the sake of efficiency, assetmanager should be configured after your static
resources.

#### Options
* assets - an object containing the list of assets
* debug - when true returns source assets rather than destination files
* webroot - strip the webroot folder name from the file paths

```
'use strict';

/**
 * Module dependencies.
 */
var express = require('express'),
	assetmanager = require('assetmanager');

module.exports = function(app, passport, db) {

	app.use(express.static(config.root + '/client'));

	app.configure(function() {
		// Import your asset file
		var assets = assetmanager.process({
			assets: require('./assets.json'),
			debug: (process.env.NODE_ENV !== 'production'),
			webroot: 'public'
		});
		// Add assets to local variables
		app.use(function (req, res, next) {
			res.locals({
				assets: assets
			});
			next();
		});

		// ... Your CODE

	});

	// ... Your CODE

};
```

#### Templates
Then finally in your template you can output them with whatever templating
framework you use. Using swig your main layout template might look something
like this:

```
{% for file in assets.main.css %}
	<link rel="stylesheet" href="{{file}}">
{% endfor %}

{% for file in assets.main.js %}
	<script type="text/javascript" src="{{file}}"></script>
{% endfor %}
```

And in perhaps a secondary layout your second group of files:

```
{% for file in assets.secondary.css %}
	<link rel="stylesheet" href="{{file}}">
{% endfor %}

{% for file in assets.secondary.js %}
	<script type="text/javascript" src="{{file}}"></script>
{% endfor %}
```
