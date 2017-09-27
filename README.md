# AsciiDoctor-RFC

[![Build
Status](https://travis-ci.org/riboseinc/asciidoctor-rfc.svg?branch=master)](https://travis-ci.org/riboseinc/asciidoctor-rfc)

A gem that processes [Asciidoctor](http://asciidoctor.org) input to generate RFC XML output, a format used to format RFC proposals (https://tools.ietf.org/html/rfc7991).

Currently generates only v3 RFC XML (RFC 7991).

## Installation

Add this line to your application's Gemfile:

```ruby
gem "asciidoctor-rfc"
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install asciidoctor-rfc
```

## Usage

Converting to RFC XML is a simple as running the ./bin/asciidoctor-rfc script using Ruby and passing our AsciiDoc document as the first argument.

```
$ ruby ./bin/asciidoctor-rfc example.adoc
```

When the script completes, you should see the file `example.xml` in the same directory.

## Syntax

The converter tries to follow native Asciidoc formatting as much as possible, including built-in attributes and styles. On occasion, it introduces additional attributes for RFC XML that are not present in Asciidoc.

The following Asciidoc elements are not supported:
* front/boilerplate

The following is a walkthrough of Asciidoc features as they map to RFC XML v3; mappings are given in curly brackets.

```asciidoc
[abbrev=x] {front/title@abbrev}
= DOCUMENT TITLE {front/title}
Author;Author_2;Author_3 
  format of each entry: Firstname Middlename(s) Lastname <Email>
:ipr {rfc@ipr}
:obsoletes {rfc@obsoletes}
:updates {rfc@updates}
:submissionType {rfc@submissionType} (default is "IETF")
:indexInclude {rfc@indexInclude}
:iprExtract {rfc@iprExtract}
:sortRefs {rfc@sortRefs}
:symRefs {rfc@symRefs}
:tocInclude {rfc@tocInclude}

:name rfc-nnnn | Internet-Draft-Name * {front/seriesInfo@value}
  {front/seriesInfo@name is either "RFC" or "Internet-Draft"}
:status {front/seriesInfo@status} (status of this document)
:intendedstatus {front/seriesInfo@status} (of internet draft once published as RFC.
  Given in <seriesinfo> element with empty "name" attribute)
:rfcstatus {front/seriesInfo@status, front/seriesInfo@value} 
  (of RFC: "full-standard|bcp|fyi number", or "info|exp|historic".
  In the latter case, value is empty.
  Given in <seriesinfo> element with empty "name" attribute)
:stream {front/seriesInfo@stream} (default is "IETF")

:fullname {front/author@fullname} (redundant with author line above)
:firstname {first letter used in front/author@initials}
:lastname {front/author@surname} (redundant with author line above)
:role {front/author@role}
:organization {front/author/organization}
:email {front/author/address/email} (redundant with author line above)
:fax {front/author/address/facsimile}
:uri {front/author/address/uri}
:phone {front/author/address/phone}
:postalLine {front/author/address/postal/postalline} (concatenated with "\ ") 
  (mutually exclusive with following address fields)
:street {front/author/address/postal/street} 
:city {front/author/address/postal/city} 
:region {front/author/address/postal/region} 
:country {front/author/address/postal/country} 
:code {front/author/address/postal/code} 

:fullname_2 {front/author@fullname} (redundant with second entry in author line above)
:firstname_2 {first letter used in front/author@initials}
:lastname_2 {front/author@surname} (redundant with second entry in author line above)
:role_2 {front/author@role}
:organization_2 {front/author/organization}
:email_2 {front/author/address/email} (redundant with second entry in author line above)
:fax_2 {front/author/address/facsimile}
:uri_2 {front/author/address/uri}
:phone_2 {front/author/address/phone}
:postalLine_2 {front/author/address/postal/postalline} (concatenated with "\ ") 
  (mutually exclusive with following address fields)
:street_2 {front/author/address/postal/street} 
:city_2 {front/author/address/postal/city} 
:region_2 {front/author/address/postal/region} 
:country_2 {front/author/address/postal/country} 
:code_2 {front/author/address/postal/code} 

:revdate {front/date@day, front/date@month, front/date@year}
:area {front/area} (comma delimited)
:workgroup {front/workgroup} (comma delimited)
:keyword {front/keyword} (comma delimited)

:link URL {<front/link href=URL/>},URL REL {<front/link href=URL rel=REL/>} 
  (for REL see https://tools.ietf.org/html/rfc7669)

[[id]] {front/abstract@anchor}
[abstract] {front/abstract}
The first paragraph between the document header is automatically parsed as an abstract, 
whether or not it is in abstract style.

NOTE: note

[NOTE,removeInRFC=true] {front/note@removeInRFC}
.Title {front/note/name}
===
Any admonitions between the abstract and the first section.
===

[[id]] {middle/section@anchor}
[removeInRFC=true,toc=include|exclude|default,sectnums] 
  {middle/section@removeInRFC, middle/section@toc, middle/section@numbered}
== Section title {middle/section/name}
Content content content {middle/section/t}
<<crossreference>> {.../xref@target}
<<crossreference,text>> {<xref target="crossreference">text</xref>}
http://example.com/[linktext] {<eref href="http://example.com/">linktext</eref>}

=== Subsection title {middle/section/section}
This ((<indexterm>)) {iref@item} is visible in the text,
this one is not (((indexterm, index-subterm))) {<iref item="indexterm" subitem="index-subterm"/>}.
Linebreak + {<br/>}
_Italic_ {.../em} *Bold* {.../strong} `Monospace` {.../tt}
~subscript~ {.../sub} ^superscript^ {.../sup}
[bcp14]#MUST NOT# {.../bcp14}

[[id]] {.../t@anchor}
[keepWithNext=true,keepWithPrevious=true] {.../t@keepWithNext, .../t@keepWithPrevious}
Paragraph text {.../t}

[[id]] {.../blockquote@anchor}
[quote, attribution, citation info] {.../blockquote@quotedFron, .../blockquote@cite}
# citation info is limited to a URL
Quotation {.../blockquote}

[[id]] {.../cref@anchor}
[NOTE,display=true|false,source=name] {.../cref@display, .../cref@source}
.Title {.../cref/name}
====
Any admonition inside the body of the text is a comment. {.../cref}
// Note that actual Asciidoc comments are ignored by the converter.
====

[[id]] {.../figure/sourcecode@anchor}
.Source code listing {.../figure/sourcecode@name}
[source,type,src=uri] {.../figure/sourcecode@type, {.../figure/sourcecode@src}}
# (src is mutually exclusive with listing content)
----
begin() { 
  Source code listing
}
----

[[id]] {.../figure@anchor}
.Figure 1 {.../figure/name}
====
[[id]] {.../figure/artwork@anchor}
[align=left|center|right,alt=alt_text] {.../figure/artwork@align, .../figure/artwork@alt}
....
Figures are only permitted to contain listings (sourcecode), images (artwork), 
or literal (artwork) {.../figure/artwork} 
....

[[id]] 
.Figure 2
[link=xxx,align=left|center|righti,alt=alt_text]
  {.../figure/artwork@src, .../figure/artwork@algn, .../figure/artwork@alt}
image::filename[] {.../figure/artwork}

====


[[id]] {.../ul@anchor}
[empty=true,compact] {.../ul@empty, .../ul@spacing}
* Unordered list 1 {.../ul/li}
* [[id]] {.../ul/li@anchor} Unordered list 2

[[id]] {.../ol@anchor}
[compact,start=n,group=n,arabic|loweralpha|upperralpha|lowerroman|upperroman] 
  {.../ol@empty, .../ol@start, .../ol@group, .../ol@type}
. A {.../ol/li}
. B

[[id]] {.../dl@anchor}
[horizontal,compact] {.../dl@hanging, ..../dl@spacing}
A:: {.../dl/dt} B {.../dl/dd}
[[id]] {.../dl/dt@anchor} C:: [[id]] {.../dl/dd@anchor} D

[[id]] {.../table@anchor}
.Table Title {.../table/name}
|===
|head | head {.../table/thead/tr/td}

[[id]] {.../table/tbody/tr@anchor}
h|head {.../table/tbody/tr/th} | [[id]] {.../table/tbody/tr/td@anchor} body {.../table/tbody/tr/td}
|respects colspan, rowspan| and (horizontal) align attributes of cells

[[id]] {.../table/tbody/tr@anchor}
|foot | foot {.../table/tfoot/tr/td}
|===

[[id]] {.../aside@anchor}
****
Sidebar {.../aside}
****

[[id]] {back/references@anchor}
[bibliography]
== Normative References
* [[[crossref]]] {back/references/reference@anchor} Reference1 {back/references/reference/refcontent}
[quoteTitle=false,target=uri,annotation=xyz]
  {back/references/reference/refcontent@quoteTitle, back/references/reference/refcontent@target,
  back/references/reference/refcontent@annotation}
* [[[crossref2,xreftext]]] Reference2

[[id]] {back/references@anchor}
[bibliography]
== Informative References
* [[[crossref3]]] {back/references/referencegroup, back/references/referencegroup@anchor}
** [[[crossref4]]] Reference4 {back/references/referencegroup/reference/refcontent}
** [[[crossref5]]] Reference5

[[id]] {back/section@anchor}
[appendix]
== Appendix 
Content {back/section}

```

## Development

We are following Sandi Metz's Rules for this gem, you can read the
[description of the rules here][sandi-metz] All new code should follow these
rules. If you make changes in a pre-existing file that violates these rules you
should fix the violations as part of your contribution.

### Setup

Clone the repository.

```sh
git clone https://github.com/riboseinc/asciidoctor-rfc
```

Setup your environment.

```sh
bin/setup
```

Run the test suite

```sh
bin/rspec
```

## Contributing

First, thank you for contributing! We love pull requests from everyone. By
participating in this project, you hereby grant [Ribose Inc.][riboseinc] the
right to grant or transfer an unlimited number of non exclusive licenses or
sub-licenses to third parties, under the copyright covering the contribution
to use the contribution by all means.

Here are a few technical guidelines to follow:

1. Open an [issue][issues] to discuss a new feature.
1. Write tests to support your new feature.
1. Make sure the entire test suite passes locally and on CI.
1. Open a Pull Request.
1. [Squash your commits][squash] after receiving feedback.
1. Party!

## Credits

This gem is developed, maintained and funded by [Ribose Inc.][riboseinc]

[riboseinc]: https://www.ribose.com
[issues]: https://github.com/riboseinc/ribose-ruby/issues
[squash]: https://github.com/thoughtbot/guides/tree/master/protocol/git#write-a-feature
[sandi-metz]: http://robots.thoughtbot.com/post/50655960596/sandi-metz-rules-for-developers
