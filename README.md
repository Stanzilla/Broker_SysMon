# Broker_SysMon

Broker_SysMon provides LDB brokers for simple system monitoring data sources like:

- Memory usage
- Latency
- Framerate
- Increasing rate (of memory usage)

![Screenshot](https://media.forgecdn.net/attachments/112/827/broker-sysmon.jpg)

The memory usage brokers tooltip displays a list of the top 30 addons, sorted by amount of memory consumed. Remember that addons that use libraries get blamed for the library's memory and CPU usage. Other addons are probably using the libraries as well, but the memory/CPU usage gets reported to the first addon that loads a copy of the library.

There are no options in-game. Basically you can tweak a few things at the top of Broker_SysMon.lua, but nothing you really need to at all. Most configuration should happen through your LDB display, which normally offers options for text size, color, etc.

The project screenshot shows SysMon brokers displayed through the [Blockoland](http://www.wowace.com/addons/blockoland/) LDB display addon, but please note that there are dozens of different display addons for LDB brokers out there, including ones like Bazooka, Fortress, NinjaPanel, and so forth.

Remember to [file a ticket](https://github.com/Stanzilla/Broker_SysMon/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-desc) if you find a problem or want to request a feature. If you want to help translate Broker_SysMon to languages other than English, you can do so [at the project page on wowace.com](http://www.wowace.com/addons/broker_sysmon/localization/). Thank you!
