Assessing methods for generating route networks from origin-destionation
data: jittering, routing, and visualisation
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
intra-zonal OD pairs. Thus, the entire transport system of city the size
of Edinburgh, with a population just over 500,000 people, can be
represented at the level of desire lines between the city’s 111
enumeration districts
([EDs](https://www.ons.gov.uk/methodology/geography/ukgeographies/censusgeography))
with 111^2 (12,321) rows and a number of columns depending on the number
of trip types.[^2]

Because of their small size and simplicity, OD datasets have long been
used to describe aggregate urban mobility patterns (Carey, Hendrickson,
and Siddharthan 1981). Typically, OD datasets are represented
*geographically* as straight ‘desire lines’ between zone centroids, with
all trips shown as departing from and arriving to a single centroid per
zone, for convenience, simplicity and (historically) to reduce
computational requirements. This approach, illustrated in Figure
<a href="#fig:od1"><strong>??</strong></a> below, has formed the basis
of many visualisations and research projects using OD data (e.g. Rae
2009; Calabrese et al. 2011). Connecting zones with straight lines in
this way has advantages: it can provide a quick summary of the movement
patterns between zones, particularly when attributes such as total
number of trips and the percentage of trips made by a particular mode
are represented by variable aesthetics such as line width and colour, as
illustrated in Figure <a href="#fig:od1"><strong>??</strong></a>.

<img src="overview_map1.png" title="Illustration of typicall representation of OD dataset, illustrating travel to work patterns in England. Source: author's [analysis](https://github.com/creds2/od-data) of open access data from the 2011 Census." alt="Illustration of typicall representation of OD dataset, illustrating travel to work patterns in England. Source: author's [analysis](https://github.com/creds2/od-data) of open access data from the 2011 Census." width="80%" />

However, the approach has limitations, including:

1.  people do not travel in straight lines!
2.  centroid-based desire lines obscure two-way flows (Tennekes and Chen
    2021)
3.  unrealistic concentration of travel around certain points

One way to add richness and realism to OD data is to convert the
geographic desire lines into routes on the network and then aggregate
the associated data to the route segment level to create route network
outputs (Morgan and Lovelace 2020). Route network generation from
centroid-based desire lines addresses limitations 1 and 2 outlined
above, but not 3. Recently proposed ‘jittering’ methods seek to overcome
all three limitations inherent to the centroid-based converstion of OD
datasets to geographic desire lines (Lovelace, Félix, and Carlino 2022).

<!-- In this paper we explore the potential for jittering . -->
<!-- We are concerned with more than the visualisation of the data. -->

The aim of this paper is to quantify, for the first time to the best of
our knowledge, the impact of jittering — and different input parameters
used in the jittering process — on the quality of route networks derived
from OD data.
<!-- , by  estimated flow  network from the route network results and real world datasets, and valuable open access datasets for subsequent geographic analysis steps. -->

<!-- Todo: add figure showing this? -->

# 2 Data and methods

The geographic input datasets on which the analysis presented in this
paper build are cleaned versions of open datasets representing the
transport system in Edinburgh (see Figure
<a href="#fig:overview">2.1</a>):

-   Open access cycle counter data, stored in
    [`cycle_counts_edinburgh_summary_2020-03-02-2022-01-05.geojson`](https://github.com/Robinlovelace/odnet/releases/download/0/cycle_counts_edinburgh_summary_2020-03-02-2022-01-05.geojson)
-   Open zones data, stored in
    [`iz_zones11_ed`](https://github.com/ITSLeeds/od/releases/download/v0.3.1/iz_zones11_ed.geojson)
-   Open road network data from OSM, stored as
    [`road_network_ed.geojson`](https://github.com/Robinlovelace/odnet/releases/download/0/cycle_counts_edinburgh_summary_2020-03-02-2022-01-05.geojson)

A non-geographic OD dataset representing trips between the zones was
also generated from the UK National travel survey 2011 data and saved as
a [.csv
file](https://github.com/ITSLeeds/od/releases/download/v0.3.1/od_iz_ed.csv),
the first three elements of which are presented in the table below.

| geo_code1 | geo_code2 | all | train | bus | car_driver | car_passenger | bicycle | foot |
|:----------|:----------|----:|------:|----:|-----------:|--------------:|--------:|-----:|
| S02001576 | S02001576 | 151 |     0 |   6 |         61 |             7 |       5 |   70 |
| S02001576 | S02001577 | 132 |     0 |  11 |         84 |            10 |      11 |   15 |
| S02001576 | S02001578 |  40 |     0 |   5 |         32 |             2 |       0 |    1 |

Table 2.1: Sample of three rows from the OD dataset used in this paper
(from home and other modes not shown).

![Figure 2.1: Overview of the study area and the input geographic
datasets. Dot size is proportional to mean cycle count at counter
locations.](README_files/figure-gfm/overview-1.png)

To test the performance of different parameters and settings for the
OD-to-route-network conversion process, we focussed only on cycling
trips as these were measured in the counter dataset mentioned. The
following parameters were adjusted to explore their importance, in
roughly descending order of frequency of mentions in the literature:

1.  The routing profile used, which can ‘prefer’ differet route types,
    resulting in ‘quiet’ to ‘fast’ networks (Desjardins et al. 2021)
2.  The level of disaggregation, ranging from none to full
    disaggregation (on desire line and route per trip) (Jafari et al.
    2015)
3.  Jittering strategy used to sample origin and destination points
    within zones (Lovelace, Félix, and Carlino 2022)

<!-- To run algorithm you need a minimum of three inputs, examples of which are provided in the `data/` folder of this repo: -->
<!-- 1. A .csv file containing OD data with two columns containing zone IDs (specified with  `--origin-key=geo_code1 --destination-key=geo_code2` by default) and other columns representing trip counts: -->
<!-- ```{r, echo=FALSE, message=FALSE} -->
<!-- od = readr::read_csv("data/od.csv") -->
<!-- knitr::kable(od[1:3, ]) -->
<!-- ``` -->
<!-- 2. A [.geojson file](https://github.com/dabreegster/odjitter/blob/main/data/zones.geojson) representing zones that contains values matching the zone IDs in the OD data (the field containing zone IDs is specified with `--zone-name-key=InterZone` by default): -->
<!-- ```{r, echo=FALSE} -->
<!-- # zones = sf::read_sf("data/zones.geojson") -->
<!-- # zones[1:3, ] -->
<!-- ``` -->
<!-- ```{bash} -->
<!-- head -6 data/zones.geojson -->
<!-- ``` -->
<!-- 3. A [.geojson file](https://github.com/dabreegster/odjitter/blob/main/data/road_network.geojson) representing a transport network from which origin and destination points are sampled -->
<!-- ```{bash} -->
<!-- head -6 data/road_network.geojson -->
<!-- ``` -->

The jittering process was undertaken with the Rust crate `odjitter`,
which can be replicated using the following reproducible code run from a
system terminal such as Bash on Linux, PowerShell on Windows or the Mac
Terminal
([Cargo](https://doc.rust-lang.org/cargo/getting-started/installation.html)
must be installed for this to work).

First install the `odjitter` Rust crate and command line tool:

``` bash
cargo install --git https://github.com/dabreegster/odjitter
```

Generate jittered OD pairs with a `max-per-od` value of 50 as follows:

``` bash
odjitter --od-csv-path od_iz_ed.csv \
  --zones-path iz_zones11_ed.geojson \
  --subpoints-path road_network_ed.geojson \
  --max-per-od 50 --output-path output_max50.geojson
```

Try running it with a different `max-per-od` value (10 in the command
below):

``` bash
odjitter --od-csv-path od_iz_ed.csv \
  --zones-path iz_zones11_ed.geojson \
  --subpoints-path road_network_ed.geojson \
  --max-per-od 10 --output-path output_max50.geojson
```

<!-- Generate results for top 500, run once: -->

# 3 Findings

Figure <a href="#fig:output1">3.1</a> shows the output of the `jitter`
commands above visually, with/without jittering and with different
values set for `max-per-od`.

![Figure 3.1: Results at the desire line level. The top left image shows
unjittered results with origins and destinations going to zone centroids
(as in many if not most visualisations of desire lines between zones).
Top right: jittered results without disaggregation. Bottom left: result
with a maximum number of trips per jittered OD pair of 50. Bottom right:
result result with a maximum number of trips per jittered OD pair of
10.](README_files/figure-gfm/output1-1.png)

<!-- Todo: update the above figure with more variations and show resulting route networks below -->
<!-- Todo: present results comparing flow from counter data with route network results -->

The route network level results associated with the same OD pairs are
shown in Figure <a href="#fig:rnets">3.2</a>.

![Figure 3.2: Route network
results.](README_files/figure-gfm/rnets-1.png)

# 4 Discussion

The approach is not without limitations. Despite the variability of
places where the automatic bicycle counters are located, they are only
40 in number, which were used to test the method. This validation step
would benefit from having more cycling counters. It should be noted that
the OD data in use is from 2011, and that the home work travel patterns
might not be up to date. <!-- Todo: add limitations -->

# 5 Acknowledgements

This work was supported by ESRC and ADR’s [10DS
Fellowship](https://www.adruk.org/news-publications/news-blogs/esrc-and-adr-uk-funded-research-fellows-to-work-with-no10-downing-street-487/)
funding, and the Alan Turing Institute.

This research was supported by the Portuguese Foundation for Science and
Technology (FCT) with the the PARSUK Portugal-UK Bilateral Research
Fund.

# 6 Biography

<!-- All contributing authors should include a biography of no more than 50 -->
<!-- words each outlining their career stage and research interests. -->

Robin is an Associate Professor of Transport Data Science working at the
University of Leeds’ Institute for Transport Studies (ITS) and Leeds
Institute for Data Analytics (LIDA). Robin is undertaking a fellowship
to support evidence-based decision making in central government in
collaboration with the No. 10 Data Science Team and is an Alan Turing
Fellow, specialising in transport modelling, geocomputation and data
driven tools for evidence-based decision making to support policy
objectives including uptake of active travel to maximise health,
wellbeing and equity outcomes, and rapid decarbonisation of local, city,
regional and national transport systems.

Rosa is an urban cycling and active mobility researcher at Instituto
Superior Técnico - University of Lisbon, and a PhD in Transportation
Systems in the MIT Portugal program. Rosa is interested in GIS for
transportation, and has been working on cycling uptake in low cycling
maturity cities, and socioeconomic impacts of shared mobility.

Dustin is a software engineer at the Alan Turing Institute, where he’s
creating an ecosystem of interoperable digital twins to study urban
transportation and pandemics. He’s the creator of the [A/B
Street](https://abstreet.org) transportation planning platform, and a
proponent of open source code and the Rust programming language.

# 7 References

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

<div id="ref-desjardins_correlates_2021" class="csl-entry">

Desjardins, Elise, Christopher D. Higgins, Darren M. Scott, Emma Apatu,
and Antonio Páez. 2021. “Correlates of Bicycling Trip Flows in Hamilton,
Ontario: Fastest, Quietest, or Balanced Routes?” *Transportation*, June.
<https://doi.org/10.1007/s11116-021-10197-1>.

</div>

<div id="ref-jafari_investigation_2015" class="csl-entry">

Jafari, Ehsan, Mason D. Gemar, Natalia Ruiz Juri, and Jennifer Duthie.
2015. “Investigation of Centroid Connector Placement for Advanced
Traffic Assignment Models with Added Network Detail.” *Transportation
Research Record: Journal of the Transportation Research Board* 2498
(June): 19–26. <https://doi.org/10.3141/2498-03>.

</div>

<div id="ref-lovelace_jittering_2022" class="csl-entry">

Lovelace, Robin, Rosa Félix, and Dustin Carlino. 2022. “Jittering: A
Computationally Efficient Method for Generating Realistic Route Networks
from Origin-Destination Data,” January.
<https://doi.org/10.31219/osf.io/qux6g>.

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

[^2]:  In practice, not all combinations of OD pairs have trips between
    them, so the square of the number of zones is an upper limit. The
    number of rows of data in the input OD dataset we use in this paper
    has 10,394 rows, 16% fewer than the maximum that could be
    represented by trips between every combination of zones. The .csv
    file associated with this dataset representing the transport system
    in Edinburgh (albeit only for work and representing only single
    stage trips in one direction) is only 0.3 MB, a compact way of
    storing information on travel behaviour compared with alternatives
    such as large GPS datasets.
