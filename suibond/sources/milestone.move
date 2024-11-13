module suibond::milestone {
  use std::string::{String};
  use std::option::{Self, Option};


  public struct Milestone has key, store {
    id: UID,
    milestone_number: u64,

    title: String,
    description: String,

    duration_epochs: u64,

    state: u64,

    submitted_epochs: u64,
    milestone_submission: Option<ID>
  }

  // ================= METHODS =================

  public fun duration_epochs(milestone: &Milestone): u64 {
    milestone.duration_epochs
  }

  public fun submit_milestone(milestone: &mut Milestone, milestone_submission_id: ID, ctx: &mut TxContext) {
    milestone.milestone_submission = option::some(milestone_submission_id);
    milestone.submitted_epochs = ctx.epoch();
  }


  // ================= FUNCTIONS =================

  public fun new(
    milestone_number: u64,
    title: String,
    description: String,
    duration_epochs: u64,
    ctx: &mut TxContext): Milestone {
      Milestone {
        id: object::new(ctx),
        milestone_number: milestone_number,
        title: title,
        description: description,
        duration_epochs: duration_epochs,
        state: 0,
        submitted_epochs: 0,
        milestone_submission: option::none()
      }
  }
}