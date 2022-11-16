const AnimateSelectAnswerHook = {
  mounted() {
    this.handleEvent("animate_select_answer", data => {
      if (this.running) return

      this.running = true
      this.el.querySelectorAll("[data-select-answer-final]").forEach(el => { delete el.dataset.selectAnswerFinal })
      this.select(data.steps, 0)
    })
  },

  select(steps, i) {
    const { student_id, pause } = steps[i]
    const studentEl = this.el.querySelector(`#student-${student_id}`)

    if (pause) {
      studentEl.dataset.selectAnswerIntermediate = true
      setTimeout(() => {
        delete studentEl.dataset.selectAnswerIntermediate
        this.select(steps, i + 1)
      }, pause)
    } else {
      studentEl.dataset.selectAnswerFinal = true
      this.running = false
    }
  }
}

export default AnimateSelectAnswerHook
