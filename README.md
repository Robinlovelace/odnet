Disaggregating origin-destination data: methods, implementations, and
optimal parameters for generating accurate route networks for
sustainable transport planning
================

<!-- README.md is generated from README.Rmd. Please edit that file -->

# 1 Introduction

Origin-destination (OD) datasets are used to represents movement through
geographic space, from an origin (O) to a destination (D). Also referred
to as ‘flow data’[^1] OD datasets usually contain not only information
about where they start or end, but also about the amount of movement
between zones (which are often represented by a zone centroid) or other
geographic entities. Because of their ability to encode a large amount
of information about millions of trips in a relatively small amount of
storage space, with the maximum number of rows in an aggregate OD
dataset equal to square of the number of zones squared, including
intra-zonal OD pairs. Thus, the entire transport system of London can be
represented, albeit simplistically, as an OD dataset representing
movement between the city’s 33 boroughs with only 33^2 (1089) rows and a
number of columns depending on the number of trip types.

Because of these easy-to-use characteristics, OD datasets have long been
used to describe aggregate urban mobility patterns (Carey, Hendrickson,
and Siddharthan 1981). Typically, OD datasets are represented
*geographically* as straight ‘desire lines’ between zone centroids, with
all trips shown as departing from and arriving to a single centroid per
zone, for convenience, simplicity and (historically) to reduce
computational requirements. This approach, illustrated in Figure
<a href="#fig:od1">1.1</a> below, has formed the basis of many
visualisations and research projects using OD data (e.g. Rae 2009;
Calabrese et al. 2011).

![Figure 1.1: Illustration of typicall representation of OD dataset,
illustrating travel to work patterns in England. Source: author’s
[analysis](https://github.com/creds2/od-data) of open access data from
the 2011 Census.](overview_map1.png)

Connecting zones with straight lines in this way has advantages: it can
provide a quick summary of the movement patterns between zones,
particularly when attributes such as total number of trips and the
percentage of trips made by a particular mode are represented by
variable aesthetics such as line width and colour, as illustrated in
Figure <a href="#fig:od1">1.1</a>.

However, the approach has limitations, including:

1.  people do not travel in straight lines!
2.  centroid-based desire lines obscure two-way flows (Tennekes and Chen
    2021)
3.  incorrect concentration of travel around certain points

One way to add richness and realism to OD data is to convert the
geographic desire lines into routes on the network and then aggregate
the associated data to the route segment level to create route network
outputs (Morgan and Lovelace 2020). Route network generation from
centroid-based desire lines addresses limitations 1 and 2 outlined
above, but not 3. In this paper we explore the potential for different
‘jittering’ and disaggregation approaches to address limitations 1 to 3.
Unlike some previous methodological papers on OD data, we are not only
concerned with the visualisation of the data. The aim is to not only
create informative visualisations but also to generate accurate results,
measured as a correlation between estimated flow on the network from the
route network results and real world datasets, and valuable open access
datasets for subsequent geographic analysis steps.

<!-- Todo: add figure showing this? -->

# 2 Data and methods

To run algorithm you need a minimum of three inputs, examples of which
are provided in the `data/` folder of this repo:

1.  A .csv file containing OD data with two columns containing zone IDs
    (specified with `--origin-key=geo_code1 --destination-key=geo_code2`
    by default) and other columns representing trip counts:

| geo_code1 | geo_code2 | all | from_home | train | bus | car_driver | car_passenger | bicycle | foot | other |
|:----------|:----------|----:|----------:|------:|----:|-----------:|--------------:|--------:|-----:|------:|
| S02001616 | S02001616 |  82 |         0 |     0 |   3 |          6 |             0 |       2 |   71 |     0 |
| S02001616 | S02001620 | 188 |         0 |     0 |  42 |         26 |             3 |      11 |  105 |     1 |
| S02001616 | S02001621 |  99 |         0 |     0 |  13 |          7 |             3 |      15 |   61 |     0 |

2.  A [.geojson
    file](https://github.com/dabreegster/odjitter/blob/main/data/zones.geojson)
    representing zones that contains values matching the zone IDs in the
    OD data (the field containing zone IDs is specified with
    `--zone-name-key=InterZone` by default):

<!-- -->

    #> {
    #> "type": "FeatureCollection",
    #> "name": "zones_min",
    #> "crs": { "type": "name", "properties": { "name": "urn:ogc:def:crs:OGC:1.3:CRS84" } },
    #> "features": [
    #> { "type": "Feature", "properties": { "InterZone": "S02001616", "Name": "Merchiston and Greenhill", "TotPop2011": 5018, "ResPop2011": 4730, "HHCnt2011": 2186, "StdAreaHa": 126.910911, "StdAreaKm2": 1.269109, "Shape_Leng": 9073.5402482000009, "Shape_Area": 1269109.10155 }, "geometry": { "type": "MultiPolygon", "coordinates": [ [ [ [ -3.2040366, 55.9333372 ], [ -3.2036354, 55.9321624 ], [ -3.2024036, 55.9321874 ], [ -3.2019838, 55.9315586 ], [ -3.2005071, 55.9317411 ], [ -3.199902, 55.931113 ], [ -3.2033504, 55.9308279 ], [ -3.2056319, 55.9309507 ], [ -3.2094979, 55.9308666 ], [ -3.2109753, 55.9299985 ], [ -3.2107073, 55.9285904 ], [ -3.2124928, 55.927854 ], [ -3.2125633, 55.9264661 ], [ -3.2094928, 55.9265616 ], [ -3.212929, 55.9260741 ], [ -3.2130774, 55.9264384 ], [ -3.2183973, 55.9252709 ], [ -3.2208941, 55.925282 ], [ -3.2242732, 55.9258683 ], [ -3.2279975, 55.9277452 ], [ -3.2269867, 55.928489 ], [ -3.2267625, 55.9299817 ], [ -3.2254561, 55.9307854 ], [ -3.224148, 55.9300725 ], [ -3.2197791, 55.9315472 ], [ -3.2222706, 55.9339127 ], [ -3.2224909, 55.934809 ], [ -3.2197844, 55.9354692 ], [ -3.2204535, 55.936195 ], [ -3.218362, 55.9368806 ], [ -3.2165749, 55.937069 ], [ -3.215582, 55.9380761 ], [ -3.2124132, 55.9355465 ], [ -3.212774, 55.9347972 ], [ -3.2119068, 55.9341947 ], [ -3.210138, 55.9349668 ], [ -3.208051, 55.9347716 ], [ -3.2083105, 55.9364224 ], [ -3.2053546, 55.9381495 ], [ -3.2046077, 55.9395298 ], [ -3.20356, 55.9380951 ], [ -3.2024323, 55.936318 ], [ -3.2029121, 55.935831 ], [ -3.204832, 55.9357555 ], [ -3.2040366, 55.9333372 ] ] ] ] } },

3.  A [.geojson
    file](https://github.com/dabreegster/odjitter/blob/main/data/road_network.geojson)
    representing a transport network from which origin and destination
    points are sampled

<!-- -->

    #> {
    #> "type": "FeatureCollection",
    #> "name": "road_network_min",
    #> "crs": { "type": "name", "properties": { "name": "urn:ogc:def:crs:OGC:1.3:CRS84" } },
    #> "features": [
    #> { "type": "Feature", "properties": { "osm_id": "3468", "name": "Albyn Place", "highway": "tertiary", "waterway": null, "aerialway": null, "barrier": null, "man_made": null, "access": null, "bicycle": null, "service": null, "z_order": 4, "other_tags": "\"lit\"=>\"yes\",\"lanes\"=>\"3\",\"maxspeed\"=>\"20 mph\",\"sidewalk\"=>\"both\",\"lanes:forward\"=>\"2\",\"lanes:backward\"=>\"1\"" }, "geometry": { "type": "LineString", "coordinates": [ [ -3.207438, 55.9533584 ], [ -3.2065953, 55.9535098 ] ] } },

The `jitter` function requires you to set the maximum number of trips
for all trips in the jittered result. A value of 1 will create a line
for every trip in the dataset, a value above the maximum number of trips
in the ‘all’ column in the OD ata will result in a jittered dataset that
has the same number of desire lines (the geographic representation of OD
pairs) as in the input (50 in this case).

With reference to the test data in this repo, you can run the `jitter`
command line tool as follows:

    #> Scraped 7 zones from data/zones.geojson
    #> Scraped 5073 subpoints from data/road_network.geojson
    #> Disaggregating OD data
    #> Wrote output_max50.geojson

Try running it with a different `max-per-od` value (10 in the command
below):

    #> Scraped 7 zones from data/zones.geojson
    #> Scraped 5073 subpoints from data/road_network.geojson
    #> Disaggregating OD data
    #> Wrote output_max10.geojson

# 3 Outputs

The figure below shows the output of the `jitter` commands above
visually, with the left image showing unjittered results with origins
and destinations going to zone centroids (as in many if not most
visualisations of desire lines between zones), the central image showing
the result after setting `max-per-od` argument to 50, and the right hand
figure showing the result after setting `max-per-od` to 10.

<img src="README_files/figure-gfm/unnamed-chunk-9-1.png" width="30%" /><img src="README_files/figure-gfm/unnamed-chunk-9-2.png" width="30%" /><img src="README_files/figure-gfm/unnamed-chunk-9-3.png" width="30%" />

# 4 Findings

# 5 Discussion

# 6 Acknowledgements

Acknowledgement should be made of any funding bodies who have supported
the work reported in the paper, of those who have given permission for
their work to be reproduced or of individuals whose particular
assistance is due recognition. Acknowledge data providers here where
appropriate.

# 7 Biography

All contributing authors should include a biography of no more than 50
words each outlining their career stage and research interests.

# 8 References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-calabrese_estimating_2011" class="csl-entry">

Calabrese, Francesco, Giusy Di Lorenzo, Liang Liu, and Carlo Ratti.
2011. “Estimating Origin-Destination Flows Using Mobile Phone Location
Data.” *IEEE Pervasive Computing* 10 (4): 36–44.
<https://doi.org/10.1109/MPRV.2011.41>.

</div>

<div id="ref-carey_method_1981" class="csl-entry">

Carey, Malachy, Chris Hendrickson, and Krishnaswami Siddharthan. 1981.
“A Method for Direct Estimation of Origin/Destination Trip Matrices.”
*Transportation Science* 15 (1): 32–49.
<https://doi.org/10.1287/trsc.15.1.32>.

</div>

<div id="ref-morgan_travel_2020" class="csl-entry">

Morgan, Malcolm, and Robin Lovelace. 2020. “Travel Flow Aggregation:
Nationally Scalable Methods for Interactive and Online Visualisation of
Transport Behaviour at the Road Network Level.” *Environment & Planning
B: Planning & Design*, July. <https://doi.org/10.1177/2399808320942779>.

</div>

<div id="ref-rae_spatial_2009" class="csl-entry">

Rae, Alasdair. 2009. “From Spatial Interaction Data to Spatial
Interaction Information? Geovisualisation and Spatial Structures of
Migration from the 2001 UK Census.” *Computers, Environment and Urban
Systems* 33 (3): 161–78.
<https://doi.org/10.1016/j.compenvurbsys.2009.01.007>.

</div>

<div id="ref-tennekes_design_2021" class="csl-entry">

Tennekes, Martijn, and Min Chen. 2021. “Design Space of
Origin-Destination Data Visualization.” *Computer Graphics Forum* 40
(3): 323–34. <https://doi.org/10.1111/cgf.14310>.

</div>

</div>

[^1]: <https://www.ons.gov.uk/census/2011census/2011censusdata/originanddestinationdata>
