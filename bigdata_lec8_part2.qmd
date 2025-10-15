---
title: "Big Data: GeoScience part 2"
author: 
  - name: MSDE
    affiliation: Lviv University
code-fold: false
execute:
  enabled: true
  cache: true
diagram:
  cache: true
  cache-dir: ./cache
  engine:
    tikz:
      execpath: lualatex
      additional-packages: |
        \usetikzlibrary{arrows.meta}
        \usetikzlibrary{positioning}
        \usetikzlibrary{decorations.pathreplacing}
filters:
  - diagram
format: 
  revealjs:
    css: custom.css
    preview-links: auto
    slide-number: true
    theme: default
    multiplex:
      url: 'https://mplex.vitv.ly'
      secret: 'a8ec82984651e86fa95bf7dc4a1b8de2'
      id: '8c59ccb7e4dfa2211ed14fa17fb72b1b76d07c2cab789dac3e2fe06135105e8a'
---

## Spatial relationships
:::{.callout-tip icon=false}
## Overview

When working with geospatial data, you often need to do specific GIS operations based on how the data layers are located in relation to each other. For instance, finding out if a certain point is located inside an area, or whether a line intersects with another line or a polygon, are very common operations for selecting data based on spatial location.

- These kind of queries are commonly called as *{term}`spatial queries`*.
- Spatial queries are conducted based on the *{term}`topological spatial relations`* which are fundamental constructs that describe how two or more geometric objects relate to each other concerning their position and boundaries. 
  - *contains*
  - *touches*
  - *intersects* 
:::

## Topological spatial relations
:::{.callout-tip icon=false}
## DE-9IM

Computationally, conducting queries based on topological spatial relations, such as detecting if a point is inside a polygon can be done in different ways, but most GIS software rely on something called *{term}`Dimensionally Extended 9-Intersection Model`* ([DE-9IM](https://en.wikipedia.org/wiki/DE-9IM) [^DE-9IM]). DE-9IM is an ISO and OGC approved standard and a fundamental framework in GIS that is used to describe and analyze spatial relationships between geometric objects ({cite}`Clementini_1993`). DE-9IM defines the topological relations based on the interior, boundary, and exterior of two geometric shapes and how they intersect with each other (see Figure 6.34 and Figure 6.35). When doing this, the DE-9IM also considers the dimensionality of the objects. Considering the dimensionality of geometric objects is important because it determines the nature of spatial relations, influences the complexity of interactions between objects, and defines topological rules. Typically the more dimensions the geometric object has, the more complex the geometry: The `Point` objects are 0-dimensional, `LineString` and `LinearRing` are 1-dimensional and `Polygon` objects are 2-dimensional (see Figure 6.35).   

![_**Figure 6.35**. Interior, boundary and exterior for different geometric data types. The data types can be either 0, 1 or 2-dimensional._](img/DE-9IM_topology_interior_boundary_exterior.png)
:::


## Topological spatial relations
:::{.callout-tip icon=false}
## DE-9IM
When testing how two geometries relate to each other, the DE-9IM model gives a result which is called *`spatial predicate`* (also called as *`binary predicate`)*. Figure 6.36 shows eight common spatial predicates based on the spatial relationship between the geometries ({cite}`Egenhofer_1992`). Many of these predicates, such as *intersects*, *within*, *contains*, *overlaps* and *touches* are commonly used when selecting data for specific area of interest or when joining data from one dataset to another based on the spatial relation between the layers. 
There are plenty of more topological relations: altogether 512 with 2D data.
![_**Figure 6.36**. Eight common spatial predicates formed based on spatial relations between two geometries. Modified after Egenhofer et al. (1992)_.](img/spatial-relations.png)
:::

## Topological spatial relations
:::{.callout-tip icon=false}
## Types
- When the geometries have at least one point in common, the geometries are said to be *intersecting* with each other.
- When two geometries *touch* each other, they have at least one point in common (at the border in this case), but their interiors do not intersect with each other.
- When the interiors of the geometries A and B are partially on top of each other and partially outside of each other, the geometries are *overlapping* with each other.
- The spatial predicate for *covers* is when the interior of geometry B is almost totally within A, but they share at least one common coordinate at the border.
- Similarly, if geometry A is almost totally contained by the geometry B (except at least one common coordinate at the border) the spatial predicate is called *covered by*. 
:::

## Topological spatial relations
:::{.callout-tip icon=false}
## Making spatial queries in Python

In Python, all the basic spatial predicates are available from `shapely` library, including:
 
 - `.intersects()`
 - `.within()`
 - `.contains()`
 - `.overlaps()`
 - `.touches()`
 - `.covers()`
 - `.covered_by()`
 - `.equals()`
 - `.disjoint()`
 - `.crosses()`
:::

## Topological spatial relations
:::{.callout-tip icon=false}
## Making spatial queries in Python

When you want to use Python to find out how two geometric objects are related to each other topologically, you start by creating the geometries using `shapely` library. In the following, we create a couple of `Point` objects and one `Polygon` object which we can use to test how they relate to each other: 

```{python}
#| echo: true
from shapely import Point, Polygon

# Create Point objects
point1 = Point(24.952242, 60.1696017)
point2 = Point(24.976567, 60.1612500)

# Create a Polygon
coordinates = [
    (24.950899, 60.169158),
    (24.953492, 60.169158),
    (24.953510, 60.170104),
    (24.950958, 60.169990),
]
polygon = Polygon(coordinates)
```
:::

## Topological spatial relations
:::{.callout-tip icon=false}
## Making spatial queries in Python
We can check the contents of the new variables by printing them to the screen, for example, in which case we would see

```{python}
#| echo: true
print(point1)
print(point2)
print(polygon)
```

If you want to test whether these `Point` geometries stored in `point1` and `point2` are within the `polygon`, you can call the `.within()` method as follows:

```{python}
#| echo: true
point1.within(polygon)
```

```{python}
#| echo: true
point2.within(polygon)
```
:::

## Topological spatial relations {.scrollable}
:::{.callout-tip icon=false}
## Making spatial queries in Python

One of the most common spatial queries is to see if a geometry intersects or touches another one. Again, there are binary operations in `shapely` for checking these spatial relationships:

- `.intersects()` - Two objects intersect if the boundary or interior of one object intersect in any way with the boundary or interior of the other object.
- `.touches()` - Two objects touch if the objects have at least one point in common and their interiors do not intersect with any part of the other object.
   
Let's try these by creating two `LineString` geometries and test whether they intersect and touch each other:

```{python}
#| echo: true
from shapely import LineString, MultiLineString

# Create two lines
line_a = LineString([(0, 0), (1, 1)])
line_b = LineString([(1, 1), (0, 2)])
```

```{python}
#| echo: true
line_a.intersects(line_b)
```

```{python}
#| echo: true
line_a.touches(line_b)
```

As we can see, it seems that our two `LineString` objects are both intersecting and touching each other. We can confirm this by plotting the features together as a `MultiLineString`:
<!-- #endregion -->

```{python}
#| echo: true
# Create a MultiLineString from line_a and line_b
multi_line = MultiLineString([line_a, line_b])
multi_line
```
:::

## Topological spatial relations {.scrollable}
:::{.callout-tip icon=false}
## Making spatial queries in Python

However, if the lines are fully overlapping with each other they don't touch due to the spatial relationship rule in the DE-9IM. We can confirm this by checking if `line_a` touches itself:

```{python}
#| echo: true
line_a.touches(line_a)
```

No it doesn't. However, `.intersects()` and `.equals()` should produce `True` for a case when we compare the `line_a` with itself:

```{python}
#| echo: true
print("Intersects?", line_a.intersects(line_a))
print("Equals?", line_a.equals(line_a))
```
:::

## Topological spatial relations
:::{.callout-tip icon=false}
## Exercise

Use python to prove that `line_a` and `line_b` are not identical.

<!--
```python editable=true slideshow={"slide_type": ""} tags=["remove_book_cell", "hide-cell"]
# Solution

print("Line a is equal to line b: ", line_a.equals(line_b))
```
-->
:::

## Topological spatial relations {.scrollable}
:::{.callout-tip icon=false}
## Making spatial queries in Python
Following the syntax from the previous examples, we can test all different spatial predicates and assess the spatial relationship between geometries. The following prints results for all predicates between the `point1` and the `polygon` which we created earlier: 

```{python}
#| echo: true
print("Intersects?", point1.intersects(polygon))
print("Within?", point1.within(polygon))
print("Contains?", point1.contains(polygon))
print("Overlaps?", point1.overlaps(polygon))
print("Touches?", point1.touches(polygon))
print("Covers?", point1.covers(polygon))
print("Covered by?", point1.covered_by(polygon))
print("Equals?", point1.equals(polygon))
print("Disjoint?", point1.disjoint(polygon))
print("Crosses?", point1.crosses(polygon))
```

Looking at all the spatial predicates, we can see that the spatial relationship between our point and polygon object produces three `True` values: The point and polygon intersect with each other, the point is within the polygon, and the point is covered by the polygon. All the other tests correctly produce `False`, which matches with the logic of the `DE-9IM` standard. 
:::

:::{.callout-note}
## `within` vs `contains`

-  if you have many points and just one polygon and you try to find out which one of them is inside the polygon: You might need to check the separately for each point to see which one is `.within()` the polygon.
-  if you have many polygons and just one point and you want to find out which polygon contains the point: You might need to check separately for each polygon to see which one(s) `.contains()` the point.
:::

## Spatial relations
:::{.callout-tip icon=false}
## Spatial queries using geopandas

```{python}
#| echo: true
import geopandas as gpd

points = gpd.read_file("_data/Helsinki/addresses.shp")
districts = gpd.read_file("_data/Helsinki/Major_districts.gpkg")
```

```{python}
#| echo: true
print("Shape:", points.shape)
print(points.head())
```

```{python}
#| echo: true
print("Shape:", districts.shape)
print(districts.tail(5))
```

The data contains 34 address points and 23 district polygons.
:::

## Spatial relations {.scrollable}
:::{.callout-tip icon=false}
## Spatial queries using geopandas

For demonstration purposes, we are interested in finding all points that are within two areas in Helsinki region, namely `Itäinen` and `Eteläinen` (*'Eastern'* and *'Southern'* in English). Let's first select the districts using the `.loc` indexer and the listed criteria which we can use with the `.isin()` method to filter the data, as we learned already in Chapter 3:

```{python}
#| echo: true
selection = districts.loc[districts["Name"].isin(["Itäinen", "Eteläinen"])]
print(selection.head())
```

Let's now plot the layers on top of each other. The areas with red color represent the districts that we want to use for testing the spatial relationships against the point layer (shown with blue color):

```{python}
#| echo: true
base = districts.plot(facecolor="gray")
selection.plot(ax=base, facecolor="red")
points.plot(ax=base, color="blue", markersize=5)
```
:::

## Spatial relations {.scrollable}
:::{.callout-tip icon=false}
## Spatial queries using geopandas

As we can see from Figure 6.37, many points seem to be within the two selected districts. To find out which of of them are located within the Polygon, we need to conduct a Point in Polygon -query. We can do this by checking which Points in the `points` GeoDataFrame are *within* the selected polygons stored in the `selection` geodataframe. In the following, we will show how to take advantage of a method called `.sjoin()` for doing spatial queries between two GeoDataFrames. Normally, `.sjoin()` method is used for conducting a *{term}`spatial join`* between two spatial datasets, meaning that specific attribute information from a given GeoDataFrame is joined to the other one based on their topological relationship (see Chapter 6.7 for more details). However, spatial join can also be used as an efficient way to conduct spatial queries in `geopandas`. Consider the following example in which we use the `.sjoin()` method using `"within"` as the `predicate` parameter to select all points that are within the selected polygons: 
<!-- #endregion -->

```{python}
#| echo: true
selected_points = points.sjoin(selection.geometry.to_frame(), predicate="within")
```

```{python}
#| echo: true
ax = districts.plot(facecolor="gray")
ax = selection.plot(ax=ax, facecolor="red")
ax = selected_points.plot(ax=ax, color="gold", markersize=2)
```
:::

## Spatial relations {.scrollable}
:::{.callout-tip icon=false}
## Spatial queries using geopandas

As a result, we have now selected only the (golden) points that are inside the red polygons which is exactly what we wanted. Notice how we used the `selection.geometry.to_frame()` when calling the `.sjoin()` method. This is a special trick to avoid attaching any extra attributes from the `selection` geodataframe to our data, which is what `.sjoin()` method would normally do (and which it is actually designed for). As we are only interested in the geometries of the right-hand-side layer to do the selection, calling the `.geometry.to_frame()` will first select the geometry column from the `selection` layer and then converts it into a `GeoDataFrame` (which would otherwise be a GeoSeries). An alternative approach for doing the same thing is to use `selection[[selection.active_geometry_name]]`, which also returns a `GeoDataFrame` containing only a column with the geodataframe's active geometry.

In a similar manner, we can easily use the `.sjoin()` with other predicates to make selections based on how the geometries between two GeoDataFrames are related to each other. By default, the `.sjoin()` uses `"intersects"` as a spatial predicate, but it is easy to change this. For example, we can investigate which of the districts *contain* at least one point. In this case, we make a spatial join using the `disctricts` GeoDataFrame as a starting point, join the layer with the `points` and use the `"contains"` as a value to our `predicate` parameter:
<!-- #endregion -->

```{python}
#| echo: true
districts_with_points = districts.sjoin(
    points.geometry.to_frame(), predicate="contains"
)
```

```{python}
#| echo: true
ax = districts.plot(facecolor="gray")
ax = districts_with_points.plot(ax=ax, edgecolor="gray")
ax = points.plot(ax=ax, color="red", markersize=2)
```
:::

## Spatial relations {.scrollable}
:::{.callout-tip icon=false}
## Spatial queries using geopandas

As a result, we can now see that all the polygons marked with blue color were correctly selected as the ones which contain at least one point object. One important thing to remember whenever making spatial queries is that both layers need to share the same Coordinate Reference System for the selection to work properly. A typical reason for getting incorrect results when selecting data (likely an empty GeoDataFrame) is that one data layer is e.g. in WGS84 coordinate reference system whereas the other one is in some projected CRS, such as ETRS-LAEA. If this happens, you can easily fix the situation by defining and reprojecting both GeoDataFrames to same CRS using the `.to_crs()` method (see Chapter 6.4).  

Following the previous examples, you can easily test other topological relationships as well, by changing the value in `predicate` parameter. To find all possible spatial predicates for a given GeoDataFrame you can call:

```{python}
#| echo: true
districts.sindex.valid_query_predicates
```

As you can see, this list includes all typical spatial predicates which we covered earlier. But what is this `.sindex` that we use here? Let's investigate it a bit further: 

```{python}
#| echo: true
districts.sindex
```
:::
## Spatial relations {.scrollable}
:::{.callout-tip icon=false}
## Spatial queries using geopandas
As we can see, the `.sindex` is something called `SpatialIndex` object. This is something that `geopandas` prepares automatically for `GeoDataFrames` and as the name implies, it contains the *{term}`spatial index`* for our data. A spatial index is a special data structure that allows for efficient querying of spatial data. There are many different kind of spatial indices, but `geopandas` uses a spatial index called R-tree which is a hierarchical, tree-like structure that divides the space into nested, overlapping rectangles and indexes the bounding boxes of each geometry. The spatial index improves the performance of spatial queries, such as finding all objects that intersect with a given area. The `.sjoin()` method takes advantage of the spatial index and is therefore an extremely powerful and makes the queries faster (see Appendix 5 for further details). This comes very practical especially when working with large datasets and doing e.g. a point-in-polygon type of queries with millions of point observations. Hence, when selecting data based on topological relations, we recommend using `.sjoin()` instead of directly calling `.within()`, `.contains()` that come with the `shapely` geometries (as shown previously). 
:::

<!-- #region editable=true slideshow={"slide_type": ""} tags=["question"] -->
## Spatial relations
:::{.callout-tip icon=false}
## Exercise

How many addresses are located in each district? You can find out the answer by grouping the spatial join result based the district name (see Part I, chapter 3 for a reminder on how to group and aggregate data). 

<!--
```python editable=true slideshow={"slide_type": ""} tags=["remove_book_cell", "hide-cell"]
# Solution

# Check column names in the spatial join result
print(districts_with_points.columns.values)

# Group by district name
grouped = districts_with_points.groupby("Name")

# Count the number of rows (adress locations) in each district
grouped.index_right.count()
```
-->

:::


## Spatial join {.scrollable}
:::{.callout-note icon=false}
## Description
Spatial join is yet another classic GIS task. Retrieving table attributes from one layer and transferring them into another layer based on their spatial relationship is something you most likely need to do on a regular basis when working with geographic data. In the previous section, you learned how to perform spatial queries, such as investigating if a Point is located within a Polygon. We can use this same logic to conduct a spatial join between two layers based on their spatial relationship and transfer the information stored in one layer into the other. We could, for example, join the attributes of a polygon layer into a point layer where each point would get the attributes of a polygon that `intersects` with the point. 

In Figure 6.41, we illustrate the logic of a spatial join by showing how it is possible to combine information between spatial data layers that are located in the same area (i.e. they overlap with each other at least partially). The target here is to combine attribute information of three layers: properties, land use and buildings. Each of these three layers has their own attribute information. Transfering the information between the layers is based on how the individual points in the Properties layer intersect with these layers as shown on the left, i.e. considering different land use areas (commercial, residential, industrial, natural), as well as the building footprints containing a variety of building-related attibute information. On the right, we show the table attributes for these three layers considering the features that intersect with the four Point observations. The table at the bottom shows how the results look after all the attribute data from these layers has been combined into a single table. 

It is good to remember that spatial join is always conducted between two layers at a time. Hence, in practice, if we want to make a spatial join between these three layers shown in Figure 6.41, we first need to conduct the spatial join between Properties and Land use, and then store this information into an intermediate result. After the first join, we need to make another spatial join between the intermediate result and the third layer (here, the Buildings dataset). After these two separate spatial joins, we have achieved the final result shown at the bottom, showing for each property (row) the corresponding attributes from the land use and building layers as separate columns. In a similar manner, you could also continue joining data (attributes) from other layers as long as you need.  

![_**Figure 6.41**. Spatial join allows you to combine attribute information from multiple layers based on spatial relationship._](img/spatial-join-basic-idea.png)
:::

## Spatial join {.scrollable}
:::{.callout-note icon=false}
## sjoin details
Now as we understand the basic idea behind the spatial join, let's continue to learn a bit more about the details of spatial join. Figure 6.42 illustrates how we can do a spatial join between Point and Polygon layers, and how changing specific parameters in the way the join is conducted influence the results. In spatial join, there are two set of options that you can control, which ultimately influence how the data is transferred between the layers. You can control: 

1) How the spatial relationship between geometries should be checked (i.e. spatial predicates), and
2) What type of table join you want to conduct (inner, left, or right outer join)

The spatial predicates control how the spatial relationship between the geometries in the two data layers is checked. Only those cases where the spatial predicate returns `True` will be kept in the result. Thus, changing this option (parameter) can have a big influence on your final results after the join. In Figure 6.41 this difference is illustrated at the bottom when you compare the result tables *i* and *ii*: In the first table (*i*) the spatial predicate is `within` that gives us 4 rows that is shown in the table. However, on the second result table (*ii*), the spatial predicate `intersects` gives us 5 rows. Why is there a difference? This is because the Point with id-number 6 happens to lie exactly at the border of the Polygon C. As you might remember from the  Chapter 6.6, there is a certain difference between these two spatial predicates: The `within` predicate expects that the Point should be inside the Polygon (`False` in our case), whereas `intersects` returns `True` if at least one point is common between the geometries (`True` in our case). In a similar manner, you could change the spatial predicate to `contains`, `touches`, `overlaps` etc. and the result would change accordingly. 

It is also important to ensure that the logic for investigating these spatial relationships makes sense when deciding which spatial predicate to use. For example, it would not make any sense to check whether Layer 1 (points) contain the Layer 2 (polygons) because Point objects do not have an interior or boundary, thus lacking the ability to contain any geometric object. Doing this kind of spatial join is possible, but the result from this type of spatial join would always return an empty `GeoDataFrame`.  However, if we change the spatial join criteria and join the data between layers if the Layer 2 (polygons) contain the Layer 1 (points), this would make a perfect sense, and the query would return rows that match with this criteria.   

![_**Figure 6.42**. Different approaches to join two data layers with each other based on spatial relationships._](img/spatial-join-alternatives.png)

:::
## Spatial join {.scrollable}
:::{.callout-note icon=false}
## sjoin type
The other parameter that you can use to control how the spatial join is conducted is the spatial join type. There are three different join types that influence the outcome of the spatial join:

1. `inner join`
2. `left outer join`
3. `right outer join`
:::

## Spatial join {.scrollable}
:::{.callout-note icon=false}
## Spatial join with Python

<!-- #region editable=true slideshow={"slide_type": ""} -->
Now as we have learned the basic logic of spatial join, let's see how we can do it in Python. Spatial join can be done easily with `geopandas` using the `.sjoin()` method. Next, we will learn how to use this method to perform a spatial join between two layers:

1) `addresses` which are the locations that we geocoded previously;
2) `population grid` which is a 250m x 250m grid polygon layer that contains population information from the Helsinki Region (source: Helsinki Region Environmental Services Authority). Let's start by reading the data:

```{python}
#| echo: true
import geopandas as gpd

addr_fp = "_data/Helsinki/addresses.shp"
addresses = gpd.read_file(addr_fp)
addresses.head(2)
```

As we can see, the `addresses` variable contains address Points which represent a selection of public transport stations in the Helsinki Region.
:::
## Spatial join {.scrollable}
:::{.callout-note icon=false}
## Spatial join with Python
```{python}
#| echo: true
pop_grid_fp = "_data/Helsinki/Population_grid_2021_HSY.gpkg"
pop_grid = gpd.read_file(pop_grid_fp)
pop_grid.head(2)
```

The `pop_grid` dataset contains few columns, namely a unique `id`, the number of `inhabitants` per grid cell, and the `occupancy_rate` as percentage. 
:::

