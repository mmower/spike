## Introduction

Spike is a log file viewing & analysis (if we're being generous) tool for Rails developers.

When developing a Rails application it is not unusual to end up pouring over log files to understand why particular actions are, or are not, happening. Rails typically logs quite a lot of information and, in a production environment, there can be a lot of requests to wade through.

The aim of Spike is to make it easy to see all of your requests, narrow them down to only the most relevant, and examine the details of those requests. To do it quickly, and with a pleasant interface.

## Features

* Optimized interface (read: not many features!)
* Filter requests by controller, action, session, client, or Rails filter action (e.g. login_required)
* Display summary of request details with drill-down to parameters, rendered templates, and raw log info
* Remove specific controller:action combos (e.g. SessionController#heartbeat) using backspace
* And that's about it...

## Notes

Spike has only been tested on a handful of log files at this point. If Spike doesn't work properly on your log file please get in touch.

## Download

<a href="http://lucidmac.com/pkg/spike/Spike-1.0.8.dmg">Spike 1.0.8</a>

Spike is a universal binary for Mac OS X 10.5

## Support

If you have problems with Spike, or would like to suggest new features [we have you covered](http://getsatisfaction.com/lucidmac/products/lucidmac_spike).

## Demo

View a short [demo movie](http://www.screencast.com/users/sandbags/folders/Jing/media/cdde1cdd-a4b6-4246-a562-088daecb543c)

## Acknowledgements

* [Todd Ditchendorf](http://ditchnet.org/) for [TDParseKit](http://ditchnet.org/tdparsekit/)
* [Samo Korosec](http://froodee.at) for the Spike icon
* [Rainer Brockerhoff](http://www.brockerhoff.net/products.html) for general awesomeness in the face of problems
* [Andy Matuschak](http://andymatuschak.org/) for [Sparkle](http://sparkle.andymatuschak.org/)
* [Brandon Walkin](http://www.brandonwalkin.com/) for [BWToolkit](http://www.brandonwalkin.com/blog/2008/11/13/introducing-bwtoolkit/)

## About the author

[I](http://mattmower.com/) write Rails applications [for a living](http://reeplay.it/) and Cocoa applications as a hobby under the name [LucidMac Software](http://lucidmac.com/) 
