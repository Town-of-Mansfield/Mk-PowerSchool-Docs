# Mk-PowerSchool-Docs v23.3.28

A MkDocs template that is compatible with PowerSchool.

## About

This theme isn't packaged and deliverable by python-pip. Maybe I'll do that in the future. This repo, however, is an example of how I use the theme and bundle the output into a plugin. So you can use this as a template for a documentation plugin if you wish.

## Using this repo

If you are using this repo as a template to generate pages/documentation from markdown this section will provide you with guidance on what to modify, and what tools are available within.

### build.ps1

This is a PowerShell build script that I use when building plugins. It watches the `_src` directory for any changes and then compiles that directory into a zip file in the `_build` directory. When you run `_build.ps1` it will block the console window. You can exit by pushing `CTRL+C` on the keyboard. Normally, this build script does not cause issues, but I find it best to run it after you perform a `mkdocs build` command. It compiles the plugin on its initial startup, and sometimes it can crash if it's watching for changes and a `mkdocs build` happens. Each new file mkdocs makes will trigger the script to compile and you'll run into access issues as it tries to archive the same file at the same time.

I'll correct this at some point so it's smoother, but it's fine for now.

### mkdocs.yml

You should be familiar with mkdocs and its workflow before jumping into using this theme. See the comments below to understand each setting.

```yml
# site_name is the name of your website, it will show in the Title of pages. 
site_name: PowerSchool Customization Documentation

# this is the directory that we are going to store our markdown files to be converted into pages. 
docs_dir: _docs

# this is the directory that mkdocs build will output too when you run that command. Here it is 
# being exported to the web_root/admin/MkDocs directory which will be applied to your server
# when you upload the plugin. When you perform an mkdocs build, the build.ps1 script will compile
# a new plgin zip file for you. 
site_dir: _src/web_root/admin/MkDocs

# Site URL should be the root address of your powerschool instance. Whatever your domain address
# might be. Everything after the root domain (yourserver.powerschool.com in this example) should
# be the same as everything after the web_root directory in the site_dir setting above. 
site_url: https://yourserver.powerschool.com/admin/MkDocs

# Powerschool doesnt do directory urls with index.html, so we turn this off so all the links point
# to the html page instead of a directory. 
use_directory_urls: false

# This sets the theme. 
theme:
    name: null
    custom_dir: 'Mk-PowerSchool-Docs-Theme/'
```


### _src/plugin.xml

If you've built a PowerSchool plugin below you are probably familiar with the `plugin.xml` file. This file describes your plugin to PowerSchool when you upload it. You'll want to update some of the settings noted below to fit your needs.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<plugin xmlns="http://plugin.powerschool.pearson.com"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://plugin.powerschool.pearson.com plugin.xsd"
        name="Mk-PowerSchool-Docs"
        description="A MkDocs template that is compatible with PowerSchool."
        version="23.3.28">
    <publisher name="Your School Name Here">
        <contact email="yourcontactemail@domain.com"/>
        </publisher>
</plugin>
```

* `name`: you should update the name of your plugin, whatever you like.
* `description`: you should also describe your plugin.
* `version`: I like using date versioning for simplicity in the YY.m.d format.
* `publisher`: typically the name of your district, or your llc, or whatever you want.
* `contact email`: I think this is required, but use your email.

The `name` and `version` fields are used when compiling the plugin into a zip file. In the example above the output would be called `Mk-PowerSchool-Docs v23.3.28.zip`. 

### _src\web_root\admin\district\home.plugin.content.footer.txt

This page fragment adds a new section under the district settings page that links back to the mkdocs generated pages.

## Features

Currently, the theme supports the following features:

* Uses the PowerSchool wildcards to complete the pages. This makes your docs appear fully integrated into PowerSchool.
* Hijacks the start page menu to use as the documentation menu. Should account for any other plugin attempting to inject content into that space and remove it.
* Has PowerSchool-like breadcrumbs to help you know where you are in the documentation.
* Has a page forward and back button utilizing PowerSchools own design elements.
* Fully local, no external resources requested by the pages.

Features in the works:

* Better code blocks with highlight.js
* inline code styles.
* Collapsible navigation menu ala the readthedocs theme.
