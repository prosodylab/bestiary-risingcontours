Building a new Bestiary site
============================


This document assumes that your data has been analyzed in some way and that you
have already created ggplots that you are happy with.  Turning those into
interactable plots for exploring and displaying data consists of several steps:

1. Create finalized data file
2. Fill in app_name/ui.R
3. Fill in app_name/server.R
4. Write RMarkdown document around the interactive plots


Create finalized data file
--------------------------

The idea here is to offload all of the preprocessing and massaging of the data from the actual running of the server.
The data set up for each app should just load data without the normal recoding/reshaping/na removal/etc.
This finalized data file should then be saved in a folder
sister to your apps (within the directory that the RMarkdown file lives), so that the site is more
portable.

Create ui.R
-----------

For starters see the ui.R file in the `app` directory.  This is a super basic
version with only one subset selection and one plot.

At the top, define the options available for each subsettable factor (i.e., the levels of the factor).
For speed reasons, it's best to hard code these based on the finalized data file you created above.

Subset selections should be within a `sidebarPanel` of a `sidebarLayout`.  These
should be given a descriptive name representing what they're subsetting for later use in `server.R`.
The `label` keyword argument should be informative, and the choices should point to a set of levels above.
The `selected` keyword argument sets the initial subset.

In the `mainpanel`, a `plotOutput` is defined that sets the area for one of the plots defined in `server.R`.
A descriptive name should be given to it, and unique identifiers for `click` if you're defining any
behavior based on clicks.  There can be multiple `plotOutput` sections defined in an app.

Create server.R
---------------

In the data set up section, load your finalized data file along with any required packages
(should just be `ggplot2`, for the most part).

Once the data is loaded, define the behavior of the `shinyServer`.  For subsetting data, there are two key parts.
The first is an `eventReactive` that gets triggered when the UI element for the subset is changed and returns the list of currently
selected elements. The second is a `reactive` that subsets data based off of the selected levels.  This `reactive` is then called as
a function for the `data` argument for your `ggplot` to pass the data to the plot.  This `ggplot` should probably be designed off line,
as part of your analysis.

Create RMarkdown
----------------

To include the plot(s) in the RMarkdown page, include the `shinyAppDir` function like in `template.Rmd`, changing "app" to whatever your app is called.
Normal RMarkdown and text would surround it.

Upload to server
----------------


Upload your data somewhere on the server somehow (rsync, dropbox, scp, etc.).
There's a directory in the prosodylab home folder named data that would be good
(i.e., `~/data/app_name`)

First, ssh into the server via:

```
ssh chael@prosodylab.org
ssh prosodylab@prosodylab.cs.mcgill.ca
```

Then change to the directory for the bestiary git repo:

```
cd dev/bestiary
```

Get the latest version from GitHub:

```
git pull
```

Then we'll want to make sure that the data uploaded earlier is available to the
app:

```
cd new_app
ln -s /path/to/data/on/server data
```

In the case of the example path above, the command would be:

```
ln -s ~/data/app_name data
```

Finally, restart the shiny server to see the changes:

```
sudo service shiny-server restart
```

It should now be available at http://prosodylab.org/data/bestiary/app_name.

