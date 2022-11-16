# Todo

## Bugs
- [ ] Debounce/single health check timeout: 2nd server creates avalanche

## Permissions
- [ ] Share gateway (group based)
  - add tenant id?
  - broadcast button click for group/tenant/user id?
  - select gateway while editing room plan to prevent noise

## Infrastructure
- [ ] Use fly deployed rabbitMQ for mqtt

## Refactoring
- [ ] change all context db getters to %{} map opts
- [ ] add user to all context functions
- [ ] Add user.system? transient flag
- [ ] Remove _id from changesets
  - separate create and edit changesets
  - set only initially, prevent any further change
  - remove from edit forms
  - remove other things from changesets
  - use in side-effect calls

## Device handling
- [ ] soft deleted and non-available devices
  - mark in room plan
  - inidicator in top bar (link icon)
- [ ] Store device.battery
- [ ] pair and rename from room plan

## Lesson features
- [ ] choose student (roulette)
- [ ] teacher add student question answer
- [ ] List and delete lesson questions
- [ ] add lesson comment per student (mass assignment?)
- [ ] add qualitative lesson grade

## Infrastructure
- [ ] fly.io check handler
