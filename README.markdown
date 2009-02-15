# Spike

A Cocoa Rails log tool
Written by Matt Mower <self@mattmower.com>

# Introduction

Spike is a simple app intended to make looking for information or patterns in Rails log files a little easier. I got fed up of scrolling backwards and forwards through endless logs looking for particular requests one too many times. Spike is the result.

Open your logfile and Spike will parse all of the requests and display them in a table including the main features like controller, action, client ip, status, and so on. Select a request to show detailed information including parameters, what was used to render the request, any filters that stopped rendering, and so on.

See a quick demo [here](http://screencast.com/t/zx0mtdIfbb).

# Acknowledgements

Spike uses [TDParseKit](http://code.google.com/p/todparsekit/) by Todd Ditchendorf. 
