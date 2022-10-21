# Todo

- [ ] Remove active question 
  - save answers right away (task)
  - create button in task
- [ ] Grade show: add dividiers before lesson/bonus grade tables
- [ ] Refactor transition_lesson: extract / domain specific
- [ ] show modals based on route: lesson add bonus grade, lesson questoin options, grade add bonus grade

- [ ] Move edit room/seating_plan into form component (save button)
- [ ] Search (global and lists)
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
