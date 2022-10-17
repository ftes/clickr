# Todo

- [ ] delete lesson -> room, seating_plan -> room
  - seating_plan defines own width/height
- [ ] delete button_plan (move into room)
 
- [ ] Filter and sort lists
- [ ] Permissions
  - user as first (second?) arg to all context functions
- [ ] Bonus grade
- [ ] Delete questions
- [ ] Change question points
- [ ] Remove _id from changesets
  - separate create and edit changesets
  - set only initially, prevent any further change
  - remove from edit forms
  - remove other things from changesets
- [ ] Soft delete stale devices
  - only list non-deleted devices and buttons
  - mark deleted buttons in button plan
- [ ] Store button.last_click_at
  - mark stale buttons in button plans
- [ ] Store device.battery
