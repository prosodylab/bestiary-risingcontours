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
behavior based on clicks.

Create server.R
---------------

In the data set up section, load your finalized data file along with any required packages
(should just be `ggplot2`, for the most part).  I suggest having all data in a folder
sister to your apps (within the directory that the RMarkdown file lives), so that the site is more
portable.

Once the data is loaded, define the behavior of the `shinyServer`.  For subsetting data, there are two key parts.
The first is an `eventReactive` that gets triggered when the UI element for the subset is changed and returns the list of currently
selected elements. The second is a `reactive` that subsets data based off of the selected levels.  This `reactive` is then called as
a function for the `data` argument for your `ggplot` to pass the data to the plot.  This `ggplot` should probably be designed off line,
as part of your analysis.

Create RMarkdown
----------------

To include the
