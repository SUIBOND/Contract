module suibond::milestone {
  use std::string::{String};

  public struct Milestone has key, store {
    id: UID,
    milestone_number: u64,

    title: String,
    description: String,

    duration_epochs: u64,

    state: u64
  }

  // ================= METHODS =================


  // ================= FUNCTIONS =================
}